# Deploy Jenkins on existing VM
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"

Write-Host "=== Deploying Jenkins ===" -ForegroundColor Green

# Install Docker
Write-Host "`nInstalling Docker..." -ForegroundColor Yellow
$dockerInstall = "sudo apt-get update -qq && sudo apt-get install -y docker.io docker-compose && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker `$USER"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="$dockerInstall" --quiet

# Check if Jenkins container exists
Write-Host "`nChecking for Jenkins container..." -ForegroundColor Yellow
$jenkinsCheck = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker ps -a --filter name=jenkins --format '{{.Names}}'" --quiet 2>&1

if ($jenkinsCheck -match "jenkins") {
    Write-Host "Jenkins container exists. Starting it..." -ForegroundColor Yellow
    gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker start jenkins" --quiet
} else {
    Write-Host "Creating Jenkins container..." -ForegroundColor Yellow
    gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts" --quiet
}

Write-Host "`n=== Jenkins Deployment Complete ===" -ForegroundColor Green

# Get VM IP
$EXTERNAL_IP = gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

Write-Host "`n📋 Access Information:" -ForegroundColor Yellow
Write-Host "   Jenkins URL: http://$EXTERNAL_IP:8080" -ForegroundColor Cyan
Write-Host "`n🔑 Get initial admin password:" -ForegroundColor Yellow
Write-Host "   gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'" -ForegroundColor White

