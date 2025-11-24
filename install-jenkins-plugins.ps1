# Install Jenkins plugins via REST API
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"

# Create credentials
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_PASSWORD}"))
$headers = @{
    Authorization = "Basic $base64Auth"
}

Write-Host "=== Installing Jenkins Plugins ===" -ForegroundColor Green

# Wait for Jenkins to be ready
Write-Host "`nWaiting for Jenkins to be ready..." -ForegroundColor Yellow
$ready = $false
for ($i = 1; $i -le 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "$JENKINS_URL/api/json" -Method Get -Headers $headers -TimeoutSec 5 -ErrorAction Stop
        $ready = $true
        Write-Host "✅ Jenkins is ready!" -ForegroundColor Green
        break
    } catch {
        Write-Host "Attempt $i/20..." -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
}

if (-not $ready) {
    Write-Host "❌ Jenkins is not ready. Please wait and try again." -ForegroundColor Red
    exit 1
}

# Plugins to install
$plugins = @(
    @{Name="github"; DisplayName="GitHub plugin"},
    @{Name="maven-plugin"; DisplayName="Maven Integration plugin"},
    @{Name="workflow-aggregator"; DisplayName="Pipeline plugin"}
)

Write-Host "`nInstalling plugins..." -ForegroundColor Yellow

foreach ($plugin in $plugins) {
    Write-Host "`nInstalling: $($plugin.DisplayName)..." -ForegroundColor Cyan
    
    try {
        # Check if already installed
        $pluginList = Invoke-RestMethod -Uri "$JENKINS_URL/pluginManager/api/json?depth=1" -Method Get -Headers $headers -ErrorAction SilentlyContinue
        $installed = $pluginList.plugins | Where-Object { $_.shortName -eq $plugin.Name -and $_.enabled -eq $true }
        
        if ($installed) {
            Write-Host "  ✅ Already installed" -ForegroundColor Green
            continue
        }
        
        # Install plugin
        $installUrl = "$JENKINS_URL/pluginManager/installNecessaryPlugins"
        $body = "plugin=$($plugin.Name)&Submit=Install"
        
        try {
            Invoke-WebRequest -Uri $installUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -Headers $headers -TimeoutSec 10 -ErrorAction Stop | Out-Null
            Write-Host "  ✅ Installation initiated" -ForegroundColor Green
        } catch {
            # Try alternative method
            $installUrl2 = "$JENKINS_URL/pluginManager/install?plugin=$($plugin.Name)"
            try {
                Invoke-WebRequest -Uri $installUrl2 -Method Post -Headers $headers -TimeoutSec 10 -ErrorAction Stop | Out-Null
                Write-Host "  ✅ Installation initiated" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠️  Please install manually via web UI" -ForegroundColor Yellow
            }
        }
        
        Start-Sleep -Seconds 2
    } catch {
        Write-Host "  ⚠️  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "  Please install manually via web UI" -ForegroundColor Gray
    }
}

Write-Host "`n=== Plugin Installation Complete ===" -ForegroundColor Green
Write-Host "`nNote: Some plugins may require Jenkins restart." -ForegroundColor Yellow
Write-Host "Check plugin status at: $JENKINS_URL/pluginManager/" -ForegroundColor Cyan


