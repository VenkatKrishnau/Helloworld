# Complete Jenkins reinstallation with JDK 17 and Maven 3.9
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"

Write-Host "=== Step 1: Deleting Existing Jenkins Docker Container ===" -ForegroundColor Green

# Stop and remove existing Jenkins container
Write-Host "`nStopping and removing existing Jenkins container..." -ForegroundColor Yellow
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker stop jenkins 2>/dev/null || true"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker rm jenkins 2>/dev/null || true"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker volume rm jenkins_home 2>/dev/null || true"

Write-Host "✅ Existing Jenkins container removed" -ForegroundColor Green

Write-Host "`n=== Step 2: Creating Custom Jenkins Image with JDK 17 and Maven 3.9 ===" -ForegroundColor Green

# Create Dockerfile for custom Jenkins image
$dockerfileContent = @"
FROM jenkins/jenkins:lts

USER root

# Install JDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 1 && \
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java

# Install Maven 3.9.5
RUN curl -L https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -o /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.5 /opt/maven && \
    rm /tmp/maven.tar.gz

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME=/opt/maven
ENV PATH=`$MAVEN_HOME/bin:`$PATH

# Switch back to jenkins user
USER jenkins
"@

Write-Host "`nCreating Dockerfile on VM..." -ForegroundColor Yellow
$dockerfileContent | gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="cat > /tmp/Dockerfile"

Write-Host "Building custom Jenkins image..." -ForegroundColor Yellow
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="cd /tmp && sudo docker build -t jenkins-with-tools:latest ."

Write-Host "✅ Custom Jenkins image created" -ForegroundColor Green

Write-Host "`n=== Step 3: Deploying New Jenkins Container ===" -ForegroundColor Green
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins-with-tools:latest"

Write-Host "✅ Jenkins container deployed" -ForegroundColor Green
Write-Host "Waiting for Jenkins to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Get initial password
Write-Host "`n=== Getting Jenkins Initial Password ===" -ForegroundColor Green
$password = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null"

Write-Host "`nJenkins Initial Admin Password: $password" -ForegroundColor Cyan
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan

# Wait for Jenkins to be ready
Write-Host "`nWaiting for Jenkins to be fully ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$ready = $false

while ($attempt -lt $maxAttempts -and -not $ready) {
    try {
        $response = Invoke-WebRequest -Uri "$JENKINS_URL/api/json" -Method Get -TimeoutSec 5 -ErrorAction Stop
        $ready = $true
        Write-Host "✅ Jenkins is ready!" -ForegroundColor Green
    } catch {
        $attempt++
        Write-Host "Waiting... ($attempt/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if (-not $ready) {
    Write-Host "⚠️  Jenkins may still be initializing. Continuing anyway..." -ForegroundColor Yellow
}

Write-Host "`n=== Step 4: Enabling GitHub Plugin and Dependencies ===" -ForegroundColor Green

# Download Jenkins CLI
$CLI_JAR = "jenkins-cli.jar"
if (-not (Test-Path $CLI_JAR)) {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $CLI_JAR
}

# Enable plugins
Write-Host "`nEnabling plugins..." -ForegroundColor Yellow
$plugins = @("github", "maven-plugin", "workflow-aggregator", "git", "github-api", "github-branch-source")

foreach ($plugin in $plugins) {
    Write-Host "Enabling: $plugin..." -ForegroundColor Cyan
    java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$password" enable-plugin $plugin 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ $plugin enabled" -ForegroundColor Green
    }
    Start-Sleep -Seconds 2
}

Write-Host "`n=== Step 5: Creating Jenkins Pipeline Job ===" -ForegroundColor Green

# Create job XML
$jobXml = @"
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.47">
  <description>Hello World Spring Boot Application Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.96">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.11.4">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/venkatkrishnau/Helloworld.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>false</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"@

$jobXmlFile = "job-config-new.xml"
$jobXml | Out-File -FilePath $jobXmlFile -Encoding UTF8

# Delete existing job if exists
Write-Host "`nRemoving existing job if exists..." -ForegroundColor Yellow
java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$password" delete-job HelloWorld-Pipeline 2>&1 | Out-Null

# Create new job
Write-Host "Creating new pipeline job..." -ForegroundColor Yellow
Get-Content $jobXmlFile | java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$password" create-job HelloWorld-Pipeline 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Pipeline job created" -ForegroundColor Green
} else {
    Write-Host "⚠️  Job creation may have issues" -ForegroundColor Yellow
}

Remove-Item $jobXmlFile -ErrorAction SilentlyContinue

Write-Host "`n=== Step 6: Building and Running Application ===" -ForegroundColor Green

Write-Host "`nTriggering build..." -ForegroundColor Yellow
java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$password" build HelloWorld-Pipeline

Write-Host "`n=== ✅ All Steps Complete ===" -ForegroundColor Green
Write-Host "`nJenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Initial Password: $password" -ForegroundColor Cyan
Write-Host "Job URL: $JENKINS_URL/job/HelloWorld-Pipeline" -ForegroundColor Cyan
Write-Host "`nBuild is running. Monitor progress in Jenkins web UI." -ForegroundColor Yellow

