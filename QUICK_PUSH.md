# Quick Push to GitHub

## Prerequisites
1. ✅ Create repository on GitHub: https://github.com/new
   - Name: `Helloworld`
   - Public or Private
   - **DO NOT** initialize with README

## Push Commands

Replace `YOUR_USERNAME` with your actual GitHub username:

```powershell
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git

# Rename branch to main
git branch -M main

# Push code
git push -u origin main
```

## One-Liner (replace YOUR_USERNAME)

```powershell
git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git; git branch -M main; git push -u origin main
```

## If Repository Already Exists

If you've already added the remote, just push:

```powershell
git branch -M main
git push -u origin main
```

## Authentication

If prompted for credentials:
- **Username:** Your GitHub username
- **Password:** Use a Personal Access Token (not your GitHub password)
  - Create token: https://github.com/settings/tokens
  - Select scope: `repo`
  - Copy token and use it as password

## Troubleshooting

**Error: remote origin already exists**
```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/Helloworld.git
git push -u origin main
```

**Error: repository not found**
- Verify repository exists on GitHub
- Check repository name matches exactly
- Ensure repository is accessible (not private if using HTTPS without token)


