# Complete Jenkins setup - All steps
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$JENKINS_URL = "http://136.115.218.34:8080"

Write-Host "=== Complete Jenkins Setup ===" -ForegroundColor Green

# Step 1: Delete existing Jenkins
Write-Host "`nStep 1: Deleting existing Jenkins container..." -ForegroundColor Yellow
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker stop jenkins 2>/dev/null; sudo docker rm jenkins 2>/dev/null; echo 'Jenkins removed'"

# Step 2: Deploy standard Jenkins
Write-Host "`nStep 2: Deploying Jenkins container..." -ForegroundColor Yellow
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts"

Write-Host "Waiting for Jenkins to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Step 3: Install JDK 17 and Maven 3.9 in container
Write-Host "`nStep 3: Installing JDK 17 and Maven 3.9.5 in Jenkins container..." -ForegroundColor Yellow
$installCmd = 'sudo docker exec -u root jenkins bash -c "apt-get update && apt-get install -y openjdk-17-jdk && curl -L https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -o /tmp/maven.tar.gz && tar -xzf /tmp/maven.tar.gz -C /opt && ln -s /opt/apache-maven-3.9.5 /opt/maven && rm /tmp/maven.tar.gz"'
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$installCmd

# Get password
Write-Host "`nStep 4: Getting Jenkins initial password..." -ForegroundColor Yellow
$password = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"

Write-Host "`nJenkins Password: $password" -ForegroundColor Cyan

# Wait for Jenkins API
Write-Host "`nWaiting for Jenkins API..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Step 5: Enable plugins
Write-Host "`nStep 5: Enabling GitHub plugin and dependencies..." -ForegroundColor Yellow
$CLI_JAR = "jenkins-cli.jar"
if (-not (Test-Path $CLI_JAR)) {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $CLI_JAR
}

$plugins = @("github", "maven-plugin", "workflow-aggregator", "git", "github-api")
foreach ($plugin in $plugins) {
    java -jar $CLI_JAR -s $JENKINS_URL -auth "admin:$password" enable-plugin $plugin 2>&1 | Out-Null
    Write-Host "  Enabled: $plugin" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Step 6: Create pipeline job
Write-Host "`nStep 6: Creating Jenkins pipeline job..." -ForegroundColor Yellow
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

$jobXml | Out-File -FilePath "job-config.xml" -Encoding UTF8
Get-Content "job-config.xml" | java -jar $CLI_JAR -s $JENKINS_URL -auth "admin:$password" create-job HelloWorld-Pipeline 2>&1 | Out-Null

# Step 7: Build and run
Write-Host "`nStep 7: Building and running application..." -ForegroundColor Yellow
java -jar $CLI_JAR -s $JENKINS_URL -auth "admin:$password" build HelloWorld-Pipeline

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Password: $password" -ForegroundColor Cyan
Write-Host "Job: $JENKINS_URL/job/HelloWorld-Pipeline" -ForegroundColor Cyan

