# Jenkins Access Credentials

## 🔐 Login Information

**Jenkins URL:** http://136.115.218.34:8080

**Username:** `admin`

**Initial Admin Password:** `0429d4276e2d4ace8582eb1a3afc4feb`

## 📝 Notes

- This is the **initial admin password** generated when Jenkins was first set up
- If you completed the Jenkins setup wizard and created a new admin user, use those credentials instead
- The initial admin password is stored in: `/var/jenkins_home/secrets/initialAdminPassword` inside the Jenkins container

## 🔑 Get Password Again

If you need to retrieve the password again:

```powershell
gcloud compute ssh jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --command="sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
```

## 🔒 Security Note

- Change the default admin password after first login for security
- Or create a new admin user during the setup wizard
- Keep credentials secure and don't commit them to version control

## 📋 Quick Access

**Direct Login:**
1. Go to: http://136.115.218.34:8080
2. Username: `admin`
3. Password: `0429d4276e2d4ace8582eb1a3afc4feb`
4. Click "Sign in"

## 🛠️ CLI Access

For Jenkins CLI commands:
```powershell
java -jar jenkins-cli.jar -s http://136.115.218.34:8080 -auth admin:0429d4276e2d4ace8582eb1a3afc4feb [command]
```


