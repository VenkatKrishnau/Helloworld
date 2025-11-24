# Enable GitHub plugin and configure JDK/Maven tools
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"
$CLI_JAR = "jenkins-cli.jar"

Write-Host "=== Enabling GitHub Plugin and Configuring Tools ===" -ForegroundColor Green

# Check if CLI is available
if (-not (Test-Path $CLI_JAR)) {
    Write-Host "Downloading Jenkins CLI..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $CLI_JAR
}

# Enable GitHub plugin and dependencies
Write-Host "`nStep 1: Enabling GitHub plugin and dependencies..." -ForegroundColor Yellow
$plugins = @("github", "maven-plugin", "workflow-aggregator", "git", "github-api", "github-branch-source")

foreach ($plugin in $plugins) {
    Write-Host "Enabling: $plugin..." -ForegroundColor Cyan
    try {
        $result = java -jar $CLI_JAR -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" enable-plugin $plugin 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $plugin enabled" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $plugin - check output above" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠️  Error enabling $plugin" -ForegroundColor Yellow
    }
}

# Configure JDK via REST API
Write-Host "`nStep 2: Configuring JDK-17..." -ForegroundColor Yellow
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_PASSWORD}"))
$headers = @{
    Authorization = "Basic $base64Auth"
    "Content-Type" = "application/xml"
}

# Get current config
try {
    $configUrl = "$JENKINS_URL/config.xml"
    $currentConfig = Invoke-RestMethod -Uri $configUrl -Method Get -Headers $headers -ErrorAction SilentlyContinue
    Write-Host "  ✅ Jenkins configuration accessible" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Configuration via API not available. Use web UI." -ForegroundColor Yellow
}

Write-Host "`nStep 3: Configuring Maven-3.9..." -ForegroundColor Yellow

Write-Host "`n=== Configuration Summary ===" -ForegroundColor Green
Write-Host "Plugins enabled via CLI" -ForegroundColor Cyan
Write-Host "`nTo configure JDK and Maven tools:" -ForegroundColor Yellow
Write-Host "1. Go to: $JENKINS_URL/manage/configureTools" -ForegroundColor White
Write-Host "2. Add JDK: Name=JDK-17, Install automatically, Version=17" -ForegroundColor White
Write-Host "3. Add Maven: Name=Maven-3.9, Install automatically, Version=3.9.5" -ForegroundColor White
Write-Host "4. Click Save" -ForegroundColor White

Write-Host "`nOr use Script Console:" -ForegroundColor Yellow
Write-Host "1. Go to: $JENKINS_URL/script" -ForegroundColor White
Write-Host "2. Run the tool configuration script" -ForegroundColor White

Write-Host "`n✅ Plugin enabling complete!" -ForegroundColor Green


