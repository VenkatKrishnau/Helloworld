# PowerShell script to create GitHub repository and push code
# Prerequisites: GitHub CLI (gh) must be installed and authenticated

Write-Host "Initializing git repository..."
git init
git add .
git commit -m "Initial commit: Hello World Spring Boot application"

Write-Host "Creating GitHub repository 'Helloworld'..."
gh repo create Helloworld --public --source=. --remote=origin --push

Write-Host "Repository created and code pushed successfully!"

