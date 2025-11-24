# Create GCP VM and deploy Jenkins
# Project ID: electric-autumn-474318-q3

$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$MACHINE_TYPE = "e2-medium"

Write-Host "=== Creating GCP VM Instance ===" -ForegroundColor Green
Write-Host "Project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "Zone: $ZONE" -ForegroundColor Cyan
Write-Host "VM Name: $VM_NAME" -ForegroundColor Cyan

# Check if VM already exists
$existingVM = gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n⚠️  VM '$VM_NAME' already exists!" -ForegroundColor Yellow
    $continue = Read-Host "Continue with Jenkins deployment? (y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 0
    }
} else {
    Write-Host "`nCreating VM instance..." -ForegroundColor Yellow
    gcloud compute instances create $VM_NAME `
        --project=$PROJECT_ID `
        --zone=$ZONE `
        --machine-type=$MACHINE_TYPE `
        --image-family=ubuntu-2204-lts `
        --image-project=ubuntu-os-cloud `
        --boot-disk-size=20GB `
        --boot-disk-type=pd-standard `
        --tags=http-server `
        --scopes=https://www.googleapis.com/auth/cloud-platform

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Failed to create VM. Check errors above." -ForegroundColor Red
        exit 1
    }

    Write-Host "`n✅ VM created successfully!" -ForegroundColor Green
    Write-Host "Waiting for VM to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}

# Enable required APIs
Write-Host "`nEnabling required APIs..." -ForegroundColor Yellow
gcloud services enable compute.googleapis.com --project=$PROJECT_ID 2>&1 | Out-Null

# Setup firewall rule
Write-Host "`nSetting up firewall rule for Jenkins..." -ForegroundColor Yellow
$firewallExists = gcloud compute firewall-rules describe allow-jenkins --project=$PROJECT_ID 2>&1
if ($LASTEXITCODE -ne 0) {
    gcloud compute firewall-rules create allow-jenkins `
        --project=$PROJECT_ID `
        --allow tcp:8080 `
        --source-ranges 0.0.0.0/0 `
        --target-tags http-server `
        --description "Allow Jenkins access"
    Write-Host "✅ Firewall rule created" -ForegroundColor Green
} else {
    Write-Host "✅ Firewall rule already exists" -ForegroundColor Green
}

# Install Docker and deploy Jenkins
Write-Host "`n=== Installing Docker and Deploying Jenkins ===" -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

$installDocker = @"
sudo apt-get update -qq
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker `$USER
"@

Write-Host "Installing Docker..." -ForegroundColor Cyan
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="$installDocker" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n⚠️  Docker installation had issues, but continuing..." -ForegroundColor Yellow
}

# Check if Jenkins container already exists
Write-Host "`nChecking for existing Jenkins container..." -ForegroundColor Cyan
$jenkinsExists = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker ps -a --filter name=jenkins --format '{{.Names}}'" 2>&1

if ($jenkinsExists -match "jenkins") {
    Write-Host "Jenkins container already exists. Starting it..." -ForegroundColor Yellow
    gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker start jenkins" 2>&1 | Out-Null
} else {
    Write-Host "Deploying Jenkins Docker container..." -ForegroundColor Cyan
    gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts" 2>&1
}

Write-Host "`n=== Jenkins Deployment Complete ===" -ForegroundColor Green
Write-Host "`nGetting VM information..." -ForegroundColor Cyan

$EXTERNAL_IP = gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

Write-Host "`n✅ Jenkins is being deployed!" -ForegroundColor Green
Write-Host "`n📋 Access Information:" -ForegroundColor Yellow
Write-Host "   Jenkins URL: http://$EXTERNAL_IP:8080" -ForegroundColor Cyan
Write-Host "`n🔑 Get initial admin password:" -ForegroundColor Yellow
Write-Host "   gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'" -ForegroundColor White
Write-Host "`n⏳ Please wait 2-3 minutes for Jenkins to fully start before accessing." -ForegroundColor Yellow

