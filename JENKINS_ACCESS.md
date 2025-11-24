# Jenkins Access Information

## ✅ Jenkins Deployment Status

**VM Information:**
- Name: jenkins-vm
- Zone: us-central1-a  
- Project: electric-autumn-474318-q3
- External IP: **136.115.218.34**

**Jenkins Access:**
- **URL:** http://136.115.218.34:8080
- **Status:** Deploying (image download in progress)

## 🔑 Get Initial Admin Password

After Jenkins container starts (wait 2-3 minutes), get the password:

```powershell
gcloud compute ssh jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
```

## ✅ Verify Jenkins is Running

```powershell
gcloud compute ssh jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --command="sudo docker ps"
```

You should see a container named "jenkins" with status "Up".

## 📋 Next Steps After Jenkins is Running

1. **Access Jenkins:** http://136.115.218.34:8080
2. **Enter initial admin password** (from command above)
3. **Install suggested plugins**
4. **Install additional plugins:**
   - GitHub plugin
   - Maven Integration plugin  
   - Pipeline plugin
5. **Configure tools:**
   - JDK-17 (Install automatically)
   - Maven-3.9 (Install automatically)
6. **Create Pipeline job:**
   - Repository: https://github.com/venkatkrishnau/Helloworld.git
   - Branch: */main
   - Script Path: Jenkinsfile

## ⏳ Note

Jenkins image download and initialization may take 2-3 minutes. Wait for the container to be in "Up" status before accessing the web UI.


