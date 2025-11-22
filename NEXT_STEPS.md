# Next Steps - Execution Guide

## Current Status ✅

- ✅ Spring Boot application created
- ✅ Git repository initialized and committed
- ⏳ GitHub repository - **NEXT STEP**
- ⏳ GCP VM setup
- ⏳ Jenkins deployment
- ⏳ Jenkins configuration
- ⏳ Jenkins job creation

## Step 1: Create GitHub Repository

### Option A: Using GitHub CLI (if installed)

```powershell
# Install GitHub CLI (if not installed)
winget install --id GitHub.cli

# Authenticate
gh auth login

# Create repository and push
gh repo create Helloworld --public --source=. --remote=origin --push
```

### Option B: Manual Creation (Current Method)

1. **Go to GitHub:** https://github.com/new
2. **Repository settings:**
   - Repository name: `Helloworld`
   - Visibility: Public (or Private)
   - **DO NOT** initialize with README, .gitignore, or license
3. **Click "Create repository"**
4. **Push your code:**
   ```powershell
   git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git
   git branch -M main
   git push -u origin main
   ```
   Replace `YOUR_USERNAME` with your GitHub username.

## Step 2: Update Jenkinsfile

After creating the GitHub repository, update the `Jenkinsfile`:

```powershell
# Edit Jenkinsfile and replace YOUR_USERNAME with your GitHub username
# Line 12: url: 'https://github.com/YOUR_USERNAME/Helloworld.git'
```

Or use this command:
```powershell
$username = Read-Host "Enter your GitHub username"
(Get-Content Jenkinsfile) -replace 'YOUR_USERNAME', $username | Set-Content Jenkinsfile
git add Jenkinsfile
git commit -m "Update Jenkinsfile with GitHub username"
git push
```

## Step 3: GCP VM and Jenkins Setup

### Prerequisites Check

```powershell
# Check if gcloud is installed
gcloud --version

# If not installed, install Google Cloud SDK:
# https://cloud.google.com/sdk/docs/install
```

### Setup GCP Project

1. **Set your GCP project:**
   ```powershell
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable required APIs:**
   ```powershell
   gcloud services enable compute.googleapis.com
   ```

3. **Edit setup script:**
   - Open `setup-gcp-jenkins.ps1`
   - Replace `your-project-id` with your actual GCP project ID

4. **Run the setup script:**
   ```powershell
   .\setup-gcp-jenkins.ps1
   ```

   Or follow manual steps in `JENKINS_SETUP.md`

### Get Jenkins Access Info

After VM is created:

```powershell
# Get VM external IP
$IP = gcloud compute instances describe jenkins-vm --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
Write-Host "Jenkins URL: http://$IP:8080"

# Get initial admin password
gcloud compute ssh jenkins-vm --zone=us-central1-a --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
```

## Step 4: Configure Jenkins

1. **Access Jenkins:** `http://<VM_IP>:8080`
2. **Enter initial admin password** (from Step 3)
3. **Install suggested plugins**
4. **Install additional plugins:**
   - Manage Jenkins → Plugins → Available
   - Search and install:
     - GitHub plugin
     - Maven Integration plugin
     - Pipeline plugin

5. **Configure Tools:**
   - Manage Jenkins → Global Tool Configuration
   - **JDK:**
     - Add JDK
     - Name: `JDK-17`
     - Install automatically: ✅
     - Version: `17`
   - **Maven:**
     - Add Maven
     - Name: `Maven-3.9`
     - Install automatically: ✅
     - Version: `3.9.5`

## Step 5: Create Jenkins Pipeline Job

1. **Create new item:**
   - Click "New Item"
   - Name: `HelloWorld-Pipeline`
   - Type: Pipeline
   - Click OK

2. **Configure pipeline:**
   - Pipeline → Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/Helloworld.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
   - Save

3. **Build the job:**
   - Click "Build Now"
   - View console output

4. **Verify application:**
   ```powershell
   gcloud compute ssh jenkins-vm --zone=us-central1-a
   curl http://localhost:8080/
   curl http://localhost:8080/health
   ```

## Quick Command Reference

```powershell
# GitHub setup (manual)
git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git
git branch -M main
git push -u origin main

# GCP VM info
gcloud compute instances list
gcloud compute instances describe jenkins-vm --zone=us-central1-a

# Jenkins access
gcloud compute ssh jenkins-vm --zone=us-central1-a
sudo docker ps  # Check Jenkins container
sudo docker logs jenkins  # View Jenkins logs

# Application verification
curl http://localhost:8080/
curl http://localhost:8080/health
```

## Troubleshooting

- **Git push fails:** Check GitHub credentials and repository URL
- **GCP errors:** Verify project ID, billing enabled, and APIs enabled
- **Jenkins not accessible:** Check firewall rules and VM status
- **Build fails:** Verify JDK and Maven are configured in Jenkins

## Need Help?

Refer to:
- `SETUP_GUIDE.md` - Comprehensive guide
- `JENKINS_SETUP.md` - Detailed Jenkins setup
- `GITHUB_SETUP.md` - GitHub repository setup

