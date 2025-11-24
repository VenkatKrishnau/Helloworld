# Create Jenkins Pipeline Job to clone and build Helloworld repository
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"
$JOB_NAME = "HelloWorld-Pipeline"
$GITHUB_REPO = "https://github.com/venkatkrishnau/Helloworld.git"

Write-Host "=== Creating Jenkins Pipeline Job ===" -ForegroundColor Green
Write-Host "Job Name: $JOB_NAME" -ForegroundColor Cyan
Write-Host "Repository: $GITHUB_REPO" -ForegroundColor Cyan

# Check if Jenkins CLI is available
$CLI_JAR = "jenkins-cli.jar"
if (-not (Test-Path $CLI_JAR)) {
    Write-Host "`nDownloading Jenkins CLI..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $CLI_JAR
}

# Check if job already exists
Write-Host "`nChecking if job already exists..." -ForegroundColor Yellow
$jobExists = java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" get-job $JOB_NAME 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "⚠️  Job '$JOB_NAME' already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite existing job? (y/n)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "Cancelled. Existing job not modified." -ForegroundColor Yellow
        exit 0
    }
    Write-Host "Updating existing job..." -ForegroundColor Yellow
}

# Create job XML configuration
Write-Host "`nCreating job configuration..." -ForegroundColor Yellow
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
          <url>$GITHUB_REPO</url>
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

# Save job XML to file
$jobXmlFile = "job-config.xml"
$jobXml | Out-File -FilePath $jobXmlFile -Encoding UTF8

# Create or update job
Write-Host "Creating/updating Jenkins job..." -ForegroundColor Yellow
try {
    if ($LASTEXITCODE -eq 0 -and $overwrite -eq 'y') {
        $result = Get-Content $jobXmlFile | java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" update-job $JOB_NAME 2>&1
    } else {
        $result = Get-Content $jobXmlFile | java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" create-job $JOB_NAME 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Job '$JOB_NAME' created/updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Job creation had issues. Check output above." -ForegroundColor Yellow
        Write-Host $result -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error creating job: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease create job manually via web UI:" -ForegroundColor Yellow
    Write-Host "1. Go to: $JENKINS_URL/view/all/newJob" -ForegroundColor White
    Write-Host "2. Name: $JOB_NAME" -ForegroundColor White
    Write-Host "3. Type: Pipeline" -ForegroundColor White
    Write-Host "4. Configure: Pipeline script from SCM" -ForegroundColor White
    Write-Host "5. Repository: $GITHUB_REPO" -ForegroundColor White
    Write-Host "6. Branch: */main" -ForegroundColor White
    Write-Host "7. Script Path: Jenkinsfile" -ForegroundColor White
}

# Clean up
Remove-Item $jobXmlFile -ErrorAction SilentlyContinue

Write-Host "`n=== Job Creation Complete ===" -ForegroundColor Green
Write-Host "Job URL: $JENKINS_URL/job/$JOB_NAME" -ForegroundColor Cyan
Write-Host "`nTo build the job:" -ForegroundColor Yellow
Write-Host "java -jar $CLI_JAR -s $JENKINS_URL -auth `"$JENKINS_USER`:$JENKINS_PASSWORD`" build $JOB_NAME" -ForegroundColor White
Write-Host "`nOr access via web UI: $JENKINS_URL/job/$JOB_NAME" -ForegroundColor Cyan


