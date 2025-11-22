# Jenkins Setup Guide

This guide will help you set up Jenkins on GCP VM and configure it to build and run the Hello World Spring Boot application.

## Prerequisites

1. Google Cloud Platform account with billing enabled
2. `gcloud` CLI installed and authenticated
3. GitHub account
4. GitHub repository created (see `setup-github.ps1` or `setup-github.sh`)

## Step 1: Create GCP VM and Deploy Jenkins

### Option A: Using the provided script (Linux/Mac)

```bash
# Edit setup-gcp-jenkins.sh and set your PROJECT_ID
chmod +x setup-gcp-jenkins.sh
./setup-gcp-jenkins.sh
```

### Option B: Manual Setup

1. **Create GCP VM:**
```bash
gcloud compute instances create jenkins-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server
```

2. **Allow HTTP traffic:**
```bash
gcloud compute firewall-rules create allow-jenkins \
    --allow tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server
```

3. **SSH into the VM:**
```bash
gcloud compute ssh jenkins-vm --zone=us-central1-a
```

4. **Install Docker:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

5. **Deploy Jenkins:**
```bash
sudo docker run -d \
    --name jenkins \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts
```

6. **Get Jenkins initial admin password:**
```bash
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

7. **Get VM external IP:**
```bash
gcloud compute instances describe jenkins-vm --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## Step 2: Configure Jenkins

1. **Access Jenkins:**
   - Open browser: `http://<VM_EXTERNAL_IP>:8080`
   - Enter the initial admin password from Step 1.6
   - Install suggested plugins

2. **Install Required Plugins:**
   - Go to: Manage Jenkins → Plugins → Available
   - Install:
     - GitHub plugin
     - Maven Integration plugin
     - Pipeline plugin

3. **Configure JDK:**
   - Go to: Manage Jenkins → Global Tool Configuration
   - Under JDK, click "Add JDK"
   - Name: `JDK-17`
   - Check "Install automatically"
   - Select version: `17` (or latest)
   - Save

4. **Configure Maven:**
   - Go to: Manage Jenkins → Global Tool Configuration
   - Under Maven, click "Add Maven"
   - Name: `Maven-3.9`
   - Check "Install automatically"
   - Select version: `3.9.5` (or latest)
   - Save

## Step 3: Create Jenkins Job

### Option A: Using Jenkinsfile (Pipeline Job)

1. **Create Pipeline Job:**
   - Click "New Item"
   - Enter name: `HelloWorld-Pipeline`
   - Select "Pipeline"
   - Click OK

2. **Configure Pipeline:**
   - Scroll to Pipeline section
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/Helloworld.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
   - Save

3. **Update Jenkinsfile:**
   - Edit `Jenkinsfile` in your repository
   - Replace `YOUR_USERNAME` with your GitHub username
   - Commit and push

4. **Build:**
   - Click "Build Now"
   - View console output

### Option B: Freestyle Job

1. **Create Freestyle Job:**
   - Click "New Item"
   - Enter name: `HelloWorld-Build`
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
   ```

5. **Save and Build:**
   - Click Save
   - Click "Build Now"

## Step 4: Verify Application

After the build completes:

1. **Check if application is running:**
```bash
gcloud compute ssh jenkins-vm --zone=us-central1-a
curl http://localhost:8080/
curl http://localhost:8080/health
```

2. **View application logs:**
```bash
cat app.log
```

## Troubleshooting

- **Jenkins not accessible:** Check firewall rules and VM external IP
- **Build fails:** Ensure JDK and Maven are properly configured
- **Application not starting:** Check Java version compatibility and port availability
- **Git clone fails:** Verify repository URL and access permissions

## Cleanup

To delete resources:

```bash
gcloud compute instances delete jenkins-vm --zone=us-central1-a
gcloud compute firewall-rules delete allow-jenkins
```

