# Script to update Jenkinsfile with GitHub username
param(
    [string]$GitHubUsername = ""
)

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    Write-Host "Error: GitHub username is required" -ForegroundColor Red
    exit 1
}

Write-Host "Updating Jenkinsfile with GitHub username: $GitHubUsername" -ForegroundColor Green

$jenkinsfilePath = "Jenkinsfile"
if (Test-Path $jenkinsfilePath) {
    $content = Get-Content $jenkinsfilePath -Raw
    $content = $content -replace 'YOUR_USERNAME', $GitHubUsername
    Set-Content $jenkinsfilePath -Value $content -NoNewline
    
    Write-Host "Jenkinsfile updated successfully!" -ForegroundColor Green
    Write-Host "Repository URL: https://github.com/$GitHubUsername/Helloworld.git" -ForegroundColor Cyan
    
    # Show the updated line
    $line = Select-String -Path $jenkinsfilePath -Pattern "url:" | Select-Object -First 1
    Write-Host "Updated line: $($line.Line.Trim())" -ForegroundColor Yellow
} else {
    Write-Host "Error: Jenkinsfile not found" -ForegroundColor Red
    exit 1
}

