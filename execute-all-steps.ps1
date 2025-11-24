# Execute all steps for Jenkins setup
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$JENKINS_URL = "http://136.115.218.34:8080"

Write-Host "=== Executing All Steps ===" -ForegroundColor Green

# Step 3: Install tools
Write-Host "`nStep 3: Installing JDK 17 and Maven 3.9.5..." -ForegroundColor Yellow
$script = Get-Content step3-install-tools.sh -Raw
$script | gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="bash"

# Step 4: Get password
Write-Host "`nStep 4: Getting Jenkins password..." -ForegroundColor Yellow
$password = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
Write-Host "Password: $password" -ForegroundColor Cyan
$password | Out-File -FilePath jenkins-password.txt -NoNewline

# Wait for Jenkins
Write-Host "`nWaiting for Jenkins API..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Step 5: Enable plugins
Write-Host "`nStep 5: Enabling plugins..." -ForegroundColor Yellow
if (-not (Test-Path jenkins-cli.jar)) {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile jenkins-cli.jar
}
$pwd = Get-Content jenkins-password.txt -Raw
$plugins = @("github", "maven-plugin", "workflow-aggregator", "git", "github-api")
foreach ($p in $plugins) {
    java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" enable-plugin $p 2>&1 | Out-Null
    Write-Host "  Enabled: $p" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Step 6: Create job
Write-Host "`nStep 6: Creating pipeline job..." -ForegroundColor Yellow
if (-not (Test-Path job-config.xml)) {
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
    $jobXml | Out-File -FilePath job-config.xml -Encoding UTF8
}
Get-Content job-config.xml | java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" create-job HelloWorld-Pipeline 2>&1 | Out-Null
Write-Host "  Job created" -ForegroundColor Green

# Step 7: Build
Write-Host "`nStep 7: Building application..." -ForegroundColor Yellow
java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" build HelloWorld-Pipeline

Write-Host "`n=== Complete ===" -ForegroundColor Green
Write-Host "Jenkins: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Job: $JENKINS_URL/job/HelloWorld-Pipeline" -ForegroundColor Cyan

