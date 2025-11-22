# Complete Setup Guide: Hello World Spring Boot with Jenkins on GCP

This guide provides step-by-step instructions to complete all tasks:
1. ✅ Create Hello World Spring Boot application
2. Create GitHub repository and push code
3. Create GCP VM
4. Deploy Jenkins Docker
5. Configure Jenkins plugins
6. Create Jenkins job to build and run application

## Prerequisites

- Java 17+ installed
- Maven 3.6+ installed
- Git installed
- GitHub account
- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and authenticated
- GitHub CLI (`gh`) installed (optional but recommended)

## Task 1: ✅ Spring Boot Application

The Hello World Spring Boot application has been created with:
- `pom.xml` - Maven configuration
- `src/main/java/com/example/helloworld/HelloWorldApplication.java` - Main application class
- `src/main/java/com/example/helloworld/controller/HelloController.java` - REST controller
- `src/main/resources/application.properties` - Application configuration

**Test locally:**
```bash
mvn clean package
mvn spring-boot:run
```

Visit `http://localhost:8080` to verify.

## Task 2: Create GitHub Repository

### Option A: Using GitHub CLI (Recommended)

1. **Install GitHub CLI:**
   - Windows: `winget install --id GitHub.cli`
   - Or download from: https://cli.github.com/

2. **Authenticate:**
   ```bash
   gh auth login
   ```

3. **Create repository and push:**
   ```powershell
   # Windows PowerShell
   .\setup-github.ps1
   ```
   
   Or manually:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Hello World Spring Boot application"
   gh repo create Helloworld --public --source=. --remote=origin --push
   ```

### Option B: Manual Setup

1. **Initialize Git:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Hello World Spring Boot application"
   ```

2. **Create repository on GitHub:**
   - Go to https://github.com/new
   - Repository name: `Helloworld`
   - Choose Public
   - **DO NOT** initialize with README
   - Click "Create repository"

3. **Push code:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/Helloworld.git
   git branch -M main
   git push -u origin main
   ```

**See `GITHUB_SETUP.md` for detailed instructions.**

## Task 3: Create GCP VM

### Step 3.1: Create VM Instance

**Windows PowerShell:**
```powershell
# Edit setup-gcp-jenkins.ps1 and set your PROJECT_ID first
.\setup-gcp-jenkins.ps1
```

**Or manually:**
```bash
# Set your project ID
export PROJECT_ID="your-project-id"
export ZONE="us-central1-a"
export VM_NAME="jenkins-vm"

# Create VM
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server

# Allow HTTP traffic
gcloud compute firewall-rules create allow-jenkins \
    --allow tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server
```

### Step 3.2: Deploy Jenkins Docker

1. **SSH into VM:**
   ```bash
   gcloud compute ssh jenkins-vm --zone=us-central1-a
   ```

2. **Install Docker:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io docker-compose
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker $USER
   ```

3. **Deploy Jenkins:**
   ```bash
   sudo docker run -d \
       --name jenkins \
       -p 8080:8080 \
       -p 50000:50000 \
       -v jenkins_home:/var/jenkins_home \
       -v /var/run/docker.sock:/var/run/docker.sock \
       jenkins/jenkins:lts
   ```

4. **Get Jenkins initial password:**
   ```bash
   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```

5. **Get VM external IP:**
   ```bash
   gcloud compute instances describe jenkins-vm --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
   ```

6. **Access Jenkins:**
   - Open browser: `http://<VM_EXTERNAL_IP>:8080`
   - Enter initial admin password
   - Install suggested plugins

## Task 4: Configure Jenkins Plugins

### Step 4.1: Install Required Plugins

1. **Go to:** Manage Jenkins → Plugins → Available
2. **Search and install:**
   - GitHub plugin
   - Maven Integration plugin
   - Pipeline plugin

### Step 4.2: Configure JDK

1. **Go to:** Manage Jenkins → Global Tool Configuration
2. **Under JDK:**
   - Click "Add JDK"
   - Name: `JDK-17`
   - Check "Install automatically"
   - Select version: `17` (or latest)
   - Save

### Step 4.3: Configure Maven

1. **Go to:** Manage Jenkins → Global Tool Configuration
2. **Under Maven:**
   - Click "Add Maven"
   - Name: `Maven-3.9`
   - Check "Install automatically"
   - Select version: `3.9.5` (or latest)
   - Save

## Task 5: Create Jenkins Job

### Option A: Pipeline Job (Recommended)

1. **Create Pipeline Job:**
   - Click "New Item"
   - Name: `HelloWorld-Pipeline`
   - Select "Pipeline"
   - Click OK

2. **Configure Pipeline:**
   - Pipeline → Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/Helloworld.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
   - Save

3. **Update Jenkinsfile:**
   - Edit `Jenkinsfile` in your repository
   - Replace `YOUR_USERNAME` with your GitHub username
   - Commit and push:
     ```bash
     git add Jenkinsfile
     git commit -m "Add Jenkinsfile"
     git push
     ```

4. **Build:**
   - Click "Build Now"
   - View console output

### Option B: Freestyle Job

1. **Create Freestyle Job:**
   - Click "New Item"
   - Name: `HelloWorld-Build`
   - Select "Freestyle project"
   - Click OK

2. **Source Code Management:**
   - Select "Git"
   - Repository URL: `https://github.com/YOUR_USERNAME/Helloworld.git`
   - Branch: `*/main`

3. **Build:**
   - Add build step: "Invoke top-level Maven targets"
   - Maven version: `Maven-3.9`
   - Goals: `clean package`

4. **Post-build Actions:**
   - Add post-build step: "Execute shell"
   - Command:
     ```bash
     pkill -f helloworld || true
     nohup java -jar target/helloworld-1.0.0.jar > app.log 2>&1 &
     sleep 5
     curl http://localhost:8080/
     curl http://localhost:8080/health
     ```

5. **Save and Build:**
   - Click Save
   - Click "Build Now"

## Task 6: Verify Application

After Jenkins build completes:

1. **SSH into VM:**
   ```bash
   gcloud compute ssh jenkins-vm --zone=us-central1-a
   ```

2. **Check if application is running:**
   ```bash
   curl http://localhost:8080/
   curl http://localhost:8080/health
   ```

3. **View logs:**
   ```bash
   cat app.log
   ```

## Troubleshooting

### Jenkins not accessible
- Check firewall rules: `gcloud compute firewall-rules list`
- Verify VM external IP
- Ensure Jenkins container is running: `sudo docker ps`

### Build fails
- Verify JDK and Maven are configured in Jenkins
- Check Jenkins console output for errors
- Ensure GitHub repository URL is correct

### Application not starting
- Check Java version compatibility
- Verify port 8080 is available
- Check application logs: `cat app.log`

### Git clone fails
- Verify repository URL and access permissions
- Check if repository is public or credentials are configured

## Cleanup

To delete all resources:

```bash
gcloud compute instances delete jenkins-vm --zone=us-central1-a
gcloud compute firewall-rules delete allow-jenkins
```

## Files Created

- `pom.xml` - Maven configuration
- `src/main/java/com/example/helloworld/` - Application source code
- `src/main/resources/application.properties` - Application config
- `Jenkinsfile` - Jenkins pipeline definition
- `setup-github.ps1` / `setup-github.sh` - GitHub setup scripts
- `setup-gcp-jenkins.ps1` / `setup-gcp-jenkins.sh` - GCP/Jenkins setup scripts
- `README.md` - Application documentation
- `GITHUB_SETUP.md` - GitHub setup guide
- `JENKINS_SETUP.md` - Jenkins setup guide
- `SETUP_GUIDE.md` - This comprehensive guide

## Next Steps

1. Complete GitHub repository setup (Task 2)
2. Create GCP VM and deploy Jenkins (Task 3)
3. Configure Jenkins plugins (Task 4)
4. Create and run Jenkins job (Task 5)
5. Verify application is running (Task 6)

