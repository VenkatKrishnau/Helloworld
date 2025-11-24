# Configure Jenkins plugins and tools programmatically
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"

Write-Host "=== Configuring Jenkins ===" -ForegroundColor Green

# Wait for Jenkins to be ready
Write-Host "`nStep 1: Waiting for Jenkins to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$jenkinsReady = $false

while ($attempt -lt $maxAttempts -and -not $jenkinsReady) {
    try {
        $response = Invoke-WebRequest -Uri "$JENKINS_URL/api/json" -Method Get -TimeoutSec 5 -ErrorAction Stop
        $jenkinsReady = $true
        Write-Host "✅ Jenkins is ready!" -ForegroundColor Green
    } catch {
        $attempt++
        Write-Host "Waiting for Jenkins... ($attempt/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if (-not $jenkinsReady) {
    Write-Host "❌ Jenkins is not ready yet. Please wait and try again." -ForegroundColor Red
    exit 1
}

# Get Jenkins CLI
Write-Host "`nStep 2: Downloading Jenkins CLI..." -ForegroundColor Yellow
$cliJar = "jenkins-cli.jar"
try {
    Invoke-WebRequest -Uri "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -OutFile $cliJar -ErrorAction Stop
    Write-Host "✅ Jenkins CLI downloaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not download CLI. Will use REST API instead." -ForegroundColor Yellow
}

# Function to install plugin via REST API
function Install-Plugin {
    param($PluginName)
    
    Write-Host "Installing plugin: $PluginName..." -ForegroundColor Cyan
    
    # Check if plugin is already installed
    try {
        $pluginCheck = Invoke-RestMethod -Uri "$JENKINS_URL/pluginManager/api/json?depth=1" -Method Get -ErrorAction SilentlyContinue
        $installed = $pluginCheck.plugins | Where-Object { $_.shortName -eq $PluginName }
        if ($installed) {
            Write-Host "  ✅ $PluginName is already installed" -ForegroundColor Green
            return $true
        }
    } catch {
        # Continue to install
    }
    
    # Install plugin
    try {
        $installUrl = "$JENKINS_URL/pluginManager/installNecessaryPlugins"
        $body = @{
            dynamicLoad = "true"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$installUrl" -Method Post -Body "plugin=$PluginName&Submit=Install" -ContentType "application/x-www-form-urlencoded" -Headers @{Authorization = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('admin:' + $JENKINS_PASSWORD)))"} -ErrorAction SilentlyContinue
        
        Write-Host "  ✅ $PluginName installation initiated" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ⚠️  Could not install $PluginName automatically. Please install via web UI." -ForegroundColor Yellow
        return $false
    }
}

# Install required plugins
Write-Host "`nStep 3: Installing required plugins..." -ForegroundColor Yellow
$plugins = @("github", "maven-plugin", "workflow-aggregator")
foreach ($plugin in $plugins) {
    Install-Plugin -PluginName $plugin
    Start-Sleep -Seconds 2
}

Write-Host "`nStep 4: Configuring JDK and Maven..." -ForegroundColor Yellow
Write-Host "Note: Tool configuration requires Jenkins to be fully initialized." -ForegroundColor Gray
Write-Host "Please configure manually via web UI:" -ForegroundColor White
Write-Host "  1. Go to: Manage Jenkins → Global Tool Configuration" -ForegroundColor Cyan
Write-Host "  2. Add JDK: Name=JDK-17, Install automatically, Version=17" -ForegroundColor Cyan
Write-Host "  3. Add Maven: Name=Maven-3.9, Install automatically, Version=3.9.5" -ForegroundColor Cyan

Write-Host "`n=== Configuration Summary ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "`nRequired plugins to install via web UI:" -ForegroundColor Yellow
Write-Host "  - GitHub plugin" -ForegroundColor White
Write-Host "  - Maven Integration plugin" -ForegroundColor White
Write-Host "  - Pipeline plugin" -ForegroundColor White
Write-Host "`nTools to configure:" -ForegroundColor Yellow
Write-Host "  - JDK-17 (Install automatically)" -ForegroundColor White
Write-Host "  - Maven-3.9 (Install automatically)" -ForegroundColor White

Write-Host "`n✅ Jenkins is ready for configuration!" -ForegroundColor Green


