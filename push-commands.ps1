# Quick push commands - Edit YOUR_USERNAME below and run this file

$GitHubUsername = "YOUR_USERNAME"  # <-- REPLACE THIS with your GitHub username

if ($GitHubUsername -eq "YOUR_USERNAME") {
    Write-Host "ERROR: Please edit this file and replace YOUR_USERNAME with your actual GitHub username" -ForegroundColor Red
    Write-Host "Then run: powershell -ExecutionPolicy Bypass -File push-commands.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up remote for: $GitHubUsername" -ForegroundColor Green

# Add remote
git remote add origin "https://github.com/$GitHubUsername/Helloworld.git"

# Push to main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host "Repository: https://github.com/$GitHubUsername/Helloworld" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Push failed. Make sure:" -ForegroundColor Red
    Write-Host "1. Repository exists at https://github.com/$GitHubUsername/Helloworld" -ForegroundColor Yellow
    Write-Host "2. You have access to the repository" -ForegroundColor Yellow
    Write-Host "3. You're authenticated (may need Personal Access Token)" -ForegroundColor Yellow
}


