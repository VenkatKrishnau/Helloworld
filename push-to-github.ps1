# Script to push code to GitHub
param(
    [string]$GitHubUsername = "",
    [string]$RepoName = "Helloworld"
)

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    Write-Host "Error: GitHub username is required" -ForegroundColor Red
    Write-Host "Usage: .\push-to-github.ps1 -GitHubUsername 'your-username'" -ForegroundColor Yellow
    exit 1
}

$repoUrl = "https://github.com/$GitHubUsername/$RepoName.git"

Write-Host "`nSetting up GitHub remote..." -ForegroundColor Green
Write-Host "Repository URL: $repoUrl" -ForegroundColor Cyan

# Check if remote already exists
$existingRemote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Remote 'origin' already exists: $existingRemote" -ForegroundColor Yellow
    $update = Read-Host "Update it? (y/n)"
    if ($update -eq 'y' -or $update -eq 'Y') {
        git remote set-url origin $repoUrl
        Write-Host "Remote updated!" -ForegroundColor Green
    } else {
        Write-Host "Using existing remote" -ForegroundColor Yellow
    }
} else {
    git remote add origin $repoUrl
    Write-Host "Remote 'origin' added!" -ForegroundColor Green
}

# Rename branch to main if needed
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "`nRenaming branch from '$currentBranch' to 'main'..." -ForegroundColor Yellow
    git branch -M main
}

Write-Host "`nPushing code to GitHub..." -ForegroundColor Green
Write-Host "This may prompt for GitHub credentials..." -ForegroundColor Yellow

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Code pushed successfully!" -ForegroundColor Green
    Write-Host "Repository: $repoUrl" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Push failed. Common issues:" -ForegroundColor Red
    Write-Host "1. Repository doesn't exist on GitHub - create it first at https://github.com/new" -ForegroundColor Yellow
    Write-Host "2. Authentication failed - you may need to use a personal access token" -ForegroundColor Yellow
    Write-Host "3. Check the error message above for details" -ForegroundColor Yellow
}


