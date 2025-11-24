# Quick Authentication and Push

## Option 1: Manual Repository Creation (Fastest - 30 seconds)

1. Go to: https://github.com/new
2. Repository name: `Helloworld`
3. Choose Public
4. **DO NOT** check any initialization options
5. Click "Create repository"
6. Then run: `git push -u origin main`

## Option 2: Authenticate GitHub CLI (Then I can create repo automatically)

Run this command in your terminal:
```powershell
gh auth login
```
- Choose: HTTPS
- Choose: Login with a web browser
- Follow the prompts to authenticate

Then I can create the repository and push automatically.

## Option 3: Use Personal Access Token

If you have a GitHub Personal Access Token:
```powershell
$env:GH_TOKEN = "your-token-here"
gh repo create Helloworld --public --source=. --remote=origin --push
```

Create token at: https://github.com/settings/tokens
- Select scope: `repo`


