# Complete Jenkins deployment with automatic SSH key acceptance
$PROJECT_ID = "electric-autumn-474318-q3"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"

Write-Host "=== Completing Jenkins Deployment ===" -ForegroundColor Green

# Function to run SSH command with auto-accept
function Run-SSHCommand {
    param($Command)
    $output = gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command=$Command --ssh-flag="-o StrictHostKeyChecking=no" 2>&1
    return $output
}

# Check if Docker is installed
Write-Host "`nStep 1: Checking Docker installation..." -ForegroundColor Yellow
$dockerCheck = Run-SSHCommand "which docker"
if ($dockerCheck -match "/usr/bin/docker" -or $dockerCheck -match "docker") {
    Write-Host "✅ Docker is already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Docker..." -ForegroundColor Yellow
    Run-SSHCommand "sudo apt-get update -qq" | Out-Null
    Run-SSHCommand "sudo apt-get install -y docker.io docker-compose" | Out-Null
    Run-SSHCommand "sudo systemctl start docker" | Out-Null
    Run-SSHCommand "sudo systemctl enable docker" | Out-Null
    Write-Host "✅ Docker installed" -ForegroundColor Green
}

# Check if Jenkins container exists
Write-Host "`nStep 2: Checking Jenkins container..." -ForegroundColor Yellow
$jenkinsStatus = Run-SSHCommand "sudo docker ps -a --filter name=jenkins --format '{{.Names}}::{{.Status}}'"

if ($jenkinsStatus -match "jenkins") {
    if ($jenkinsStatus -match "Up") {
        Write-Host "✅ Jenkins container is running" -ForegroundColor Green
    } else {
        Write-Host "Starting existing Jenkins container..." -ForegroundColor Yellow
        Run-SSHCommand "sudo docker start jenkins" | Out-Null
        Write-Host "✅ Jenkins container started" -ForegroundColor Green
    }
} else {
    Write-Host "Creating Jenkins container..." -ForegroundColor Yellow
    Run-SSHCommand "sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts" | Out-Null
    Write-Host "✅ Jenkins container created and started" -ForegroundColor Green
    Write-Host "Waiting 10 seconds for Jenkins to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

# Verify Jenkins is running
Write-Host "`nStep 3: Verifying Jenkins status..." -ForegroundColor Yellow
$jenkinsRunning = Run-SSHCommand "sudo docker ps --filter name=jenkins --format '{{.Status}}'"
if ($jenkinsRunning -match "Up") {
    Write-Host "✅ Jenkins is running" -ForegroundColor Green
} else {
    Write-Host "⚠️  Jenkins may still be starting. Please wait a moment." -ForegroundColor Yellow
}

# Get initial admin password
Write-Host "`nStep 4: Getting initial admin password..." -ForegroundColor Yellow
$password = Run-SSHCommand "sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null"
if ($password -and $password.Length -gt 0) {
    Write-Host "✅ Initial admin password retrieved" -ForegroundColor Green
} else {
    Write-Host "⚠️  Password not available yet. Jenkins may still be initializing." -ForegroundColor Yellow
    Write-Host "   Try again in 30 seconds with:" -ForegroundColor White
    Write-Host "   gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'" -ForegroundColor Gray
}

# Get VM IP
$EXTERNAL_IP = gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

Write-Host "`n=== ✅ Jenkins Deployment Complete ===" -ForegroundColor Green
Write-Host "`nAccess Information:" -ForegroundColor Yellow
Write-Host "   Jenkins URL: http://$EXTERNAL_IP:8080" -ForegroundColor Cyan
Write-Host "`nInitial Admin Password:" -ForegroundColor Yellow
if ($password -and $password.Length -gt 0) {
    Write-Host "   $password" -ForegroundColor White -BackgroundColor DarkGreen
} else {
    Write-Host "   (Run command below to get password)" -ForegroundColor Gray
}
Write-Host "`nGet password manually:" -ForegroundColor Yellow
Write-Host "   gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'" -ForegroundColor White
Write-Host "`nNote: Jenkins may take 1-2 minutes to fully initialize." -ForegroundColor Yellow
Write-Host "   Wait for the web UI to be accessible before proceeding." -ForegroundColor Yellow

