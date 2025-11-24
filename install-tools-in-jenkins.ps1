# Install Java 17 and Maven in Jenkins Docker container
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"

Write-Host "=== Installing Java 17 and Maven in Jenkins Container ===" -ForegroundColor Green

# Install Java 17
Write-Host "`nStep 1: Installing Java 17..." -ForegroundColor Yellow
$installJava = "sudo docker exec jenkins bash -c 'apt-get update -qq && apt-get install -y openjdk-17-jdk'"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$installJava

# Install Maven
Write-Host "`nStep 2: Installing Maven..." -ForegroundColor Yellow
$installMaven = "sudo docker exec jenkins bash -c 'apt-get install -y maven'"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$installMaven

# Verify installations
Write-Host "`nStep 3: Verifying installations..." -ForegroundColor Yellow
$checkJava = "sudo docker exec jenkins bash -c 'java -version 2>&1 | head -3'"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$checkJava

$checkMaven = "sudo docker exec jenkins bash -c 'mvn -version 2>&1 | head -3'"
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$checkMaven

Write-Host "`n=== Installation Complete ===" -ForegroundColor Green
Write-Host "Java 17 and Maven are now installed in Jenkins container" -ForegroundColor Cyan


