# Complete remaining Jenkins setup steps
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$JENKINS_URL = "http://136.115.218.34:8080"

Write-Host "=== Completing Jenkins Setup ===" -ForegroundColor Green

# Step 1: Get Jenkins password
Write-Host "`n[1/4] Getting Jenkins password..." -ForegroundColor Yellow
$password = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
Write-Host "Password: $password" -ForegroundColor Cyan
$password | Out-File jenkins-password.txt -NoNewline

# Step 2: Wait for Jenkins API
Write-Host "`n[2/4] Waiting for Jenkins API..." -ForegroundColor Yellow
$ready = $false
for ($i = 1; $i -le 12; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "$JENKINS_URL/api/json" -Method Get -TimeoutSec 5 -ErrorAction Stop
        $ready = $true
        Write-Host "Jenkins is ready!" -ForegroundColor Green
        break
    } catch {
        Write-Host "Attempt $i/12..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if (-not $ready) {
    Write-Host "Jenkins may still be starting. Continuing anyway..." -ForegroundColor Yellow
}

# Step 3: Download CLI and enable plugins
Write-Host "`n[3/4] Enabling plugins..." -ForegroundColor Yellow
if (-not (Test-Path jenkins-cli.jar)) {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile jenkins-cli.jar
}

$pwd = Get-Content jenkins-password.txt -Raw
$plugins = @("github", "maven-plugin", "workflow-aggregator", "git", "github-api")
foreach ($p in $plugins) {
    java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" enable-plugin $p 2>&1 | Out-Null
    Write-Host "  Enabled: $p" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

# Step 4: Create job
Write-Host "`n[4/4] Creating pipeline job..." -ForegroundColor Yellow
if (-not (Test-Path job-config.xml)) {
    $jobXml = Get-Content job-config.xml
} else {
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
    $jobXml | Out-File job-config.xml -Encoding UTF8
}

Get-Content job-config.xml | java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" create-job HelloWorld-Pipeline 2>&1 | Out-Null
Write-Host "  Job created" -ForegroundColor Green

# Step 5: Build
Write-Host "`n[5/5] Triggering build..." -ForegroundColor Yellow
java -jar jenkins-cli.jar -s $JENKINS_URL -auth "admin:$pwd" build HelloWorld-Pipeline 2>&1

Write-Host "`n=== ✅ Setup Complete ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "Password: $password" -ForegroundColor Cyan
Write-Host "Job: $JENKINS_URL/job/HelloWorld-Pipeline" -ForegroundColor Cyan

