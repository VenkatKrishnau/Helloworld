# Complete Jenkins configuration script
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"

Write-Host "=== Complete Jenkins Configuration ===" -ForegroundColor Green

# Download Jenkins CLI
Write-Host "`nStep 1: Downloading Jenkins CLI..." -ForegroundColor Yellow
$cliJar = "jenkins-cli.jar"
try {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $cliJar -ErrorAction Stop
    Write-Host "✅ Jenkins CLI downloaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not download CLI" -ForegroundColor Yellow
}

# Install plugins using CLI
Write-Host "`nStep 2: Installing plugins via CLI..." -ForegroundColor Yellow
$plugins = @("github", "maven-plugin", "workflow-aggregator")

foreach ($plugin in $plugins) {
    Write-Host "Installing: $plugin..." -ForegroundColor Cyan
    try {
        $result = java -jar $cliJar -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" install-plugin $plugin -deploy 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $plugin installed" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $plugin installation may require restart" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠️  Please install $plugin via web UI" -ForegroundColor Yellow
    }
}

# Configure tools using Groovy script
Write-Host "`nStep 3: Configuring JDK and Maven..." -ForegroundColor Yellow
if (Test-Path "configure-jenkins-tools.groovy") {
    try {
        $groovyScript = Get-Content "configure-jenkins-tools.groovy" -Raw
        $result = java -jar $cliJar -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" groovy = $groovyScript 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Tools configured" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Tool configuration may need to be done via web UI" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Please configure tools via web UI" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Groovy script not found" -ForegroundColor Yellow
}

Write-Host "`n=== Configuration Summary ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "`nIf plugins/tools were not configured automatically:" -ForegroundColor Yellow
Write-Host "1. Access Jenkins web UI" -ForegroundColor White
Write-Host "2. Install plugins: Manage Jenkins → Plugins → Available" -ForegroundColor White
Write-Host "3. Configure tools: Manage Jenkins → Global Tool Configuration" -ForegroundColor White

Write-Host "`n✅ Configuration process complete!" -ForegroundColor Green


