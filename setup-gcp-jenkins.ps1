# PowerShell script to create GCP VM and deploy Jenkins
# Prerequisites: gcloud CLI must be installed and authenticated

$PROJECT_ID = "your-project-id"
$ZONE = "us-central1-a"
$VM_NAME = "jenkins-vm"
$MACHINE_TYPE = "e2-medium"

Write-Host "Creating GCP VM instance..."
gcloud compute instances create $VM_NAME `
    --project=$PROJECT_ID `
    --zone=$ZONE `
    --machine-type=$MACHINE_TYPE `
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_IPV6,subnet=default `
    --maintenance-policy=MIGRATE `
    --provisioning-model=STANDARD `
    --service-account=default `
    --scopes=https://www.googleapis.com/auth/cloud-platform `
    --tags=http-server,https-server `
    --create-disk=auto-delete=yes,boot=yes,device-name=$VM_NAME,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20231213,mode=rw,size=20,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-standard `
    --no-shielded-secure-boot `
    --shielded-vtpm `
    --shielded-integrity-monitoring `
    --labels=goog-ec-src=vm_add-gcloud `
    --reservation-affinity=any

Write-Host "Waiting for VM to be ready..."
Start-Sleep -Seconds 30

Write-Host "Installing Docker on VM..."
gcloud compute ssh $VM_NAME --zone=$ZONE --command="sudo apt-get update && sudo apt-get install -y docker.io docker-compose && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker `$USER"

Write-Host "Deploying Jenkins Docker container..."
gcloud compute ssh $VM_NAME --zone=$ZONE --command="sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts"

Write-Host "Setting up firewall rule for Jenkins..."
gcloud compute firewall-rules create allow-jenkins `
    --project=$PROJECT_ID `
    --allow tcp:8080 `
    --source-ranges 0.0.0.0/0 `
    --target-tags http-server `
    --description "Allow Jenkins access"

Write-Host "Jenkins is being deployed. Please wait a few minutes for it to start."
Write-Host "Get the initial admin password with:"
Write-Host "gcloud compute ssh $VM_NAME --zone=$ZONE --command='sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'"
Write-Host ""
$EXTERNAL_IP = gcloud compute instances describe $VM_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
Write-Host "Access Jenkins at: http://$EXTERNAL_IP:8080"

