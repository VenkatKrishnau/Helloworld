# Script to create GitHub repository and push code
# Option 1: Use Personal Access Token
# Option 2: Authenticate via web browser

param(
    [string]$Token = ""
)

Write-Host "=== Creating GitHub Repository ===" -ForegroundColor Green

# Check if already authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Already authenticated with GitHub" -ForegroundColor Green
} else {
    if ($Token) {
        Write-Host "Using provided token..." -ForegroundColor Yellow
        $env:GH_TOKEN = $Token
    } else {
        Write-Host "`nAuthentication required. Choose an option:" -ForegroundColor Yellow
        Write-Host "1. Use Personal Access Token (fastest)" -ForegroundColor Cyan
        Write-Host "2. Authenticate via web browser" -ForegroundColor Cyan
        Write-Host "`nFor option 1, create token at: https://github.com/settings/tokens" -ForegroundColor White
        Write-Host "Select scope: 'repo'" -ForegroundColor White
        Write-Host "`nThen run: .\create-repo-and-push.ps1 -Token 'your-token-here'" -ForegroundColor Yellow
        Write-Host "`nOr for option 2, run: gh auth login" -ForegroundColor Yellow
        exit 1
    }
}

# Create repository and push
Write-Host "`nCreating repository 'Helloworld'..." -ForegroundColor Green
gh repo create Helloworld --public --source=. --remote=origin --push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Repository created and code pushed successfully!" -ForegroundColor Green
    Write-Host "Repository URL: https://github.com/venkatkrishnau/Helloworld" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Failed to create repository. Error details above." -ForegroundColor Red
    Write-Host "`nTry manual authentication: gh auth login" -ForegroundColor Yellow
}

