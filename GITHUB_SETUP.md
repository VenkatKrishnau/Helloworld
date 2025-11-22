# GitHub Repository Setup Guide

This guide will help you create a GitHub repository and push the Hello World Spring Boot application.

## Prerequisites

1. GitHub account
2. GitHub CLI (`gh`) installed and authenticated, OR
3. Git installed

## Option 1: Using GitHub CLI (Recommended)

### Install GitHub CLI

**Windows (PowerShell):**
```powershell
winget install --id GitHub.cli
```

**Linux:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**Mac:**
```bash
brew install gh
```

### Authenticate GitHub CLI

```bash
gh auth login
```

Follow the prompts to authenticate.

### Create Repository and Push Code

**Windows (PowerShell):**
```powershell
.\setup-github.ps1
```

**Linux/Mac:**
```bash
chmod +x setup-github.sh
./setup-github.sh
```

## Option 2: Manual Setup (Using Git)

1. **Initialize Git repository:**
```bash
git init
git add .
git commit -m "Initial commit: Hello World Spring Boot application"
```

2. **Create repository on GitHub:**
   - Go to https://github.com/new
   - Repository name: `Helloworld`
   - Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license
   - Click "Create repository"

3. **Push code to GitHub:**
```bash
git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username.

## Verify

1. Visit your repository: `https://github.com/YOUR_USERNAME/Helloworld`
2. Verify all files are present:
   - `pom.xml`
   - `src/` directory
   - `README.md`
   - `.gitignore`

## Next Steps

After creating the repository, proceed with:
1. GCP VM setup (see `JENKINS_SETUP.md`)
2. Jenkins configuration
3. Creating Jenkins job to build and run the application

