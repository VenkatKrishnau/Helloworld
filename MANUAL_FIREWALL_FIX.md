# Manual Firewall Fix Steps

## Issue
Cannot access http://136.115.218.34:8081/ from browser even after creating firewall rule.

## Quick Fix - Run These Commands

### 1. Create/Update Firewall Rule
```powershell
gcloud compute firewall-rules create allow-http-8081 --project=electric-autumn-474318-q3 --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8081 --source-ranges=0.0.0.0/0 --target-tags=http-server --description="Allow HTTP on port 8081"
```

If rule already exists, update it:
```powershell
gcloud compute firewall-rules update allow-http-8081 --project=electric-autumn-474318-q3 --rules=tcp:8081 --source-ranges=0.0.0.0/0
```

### 2. Add http-server Tag to VM
```powershell
gcloud compute instances add-tags jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --tags=http-server
```

### 3. Verify External IP
```powershell
gcloud compute instances describe jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

### 4. Ensure Application Binds to All Interfaces
The application should bind to 0.0.0.0 (all interfaces) by default. If not, add to `application.properties`:
```
server.address=0.0.0.0
```

## Verify Firewall Rule
```powershell
gcloud compute firewall-rules list --project=electric-autumn-474318-q3 --filter="name=allow-http-8081"
```

## Verify VM Tags
```powershell
gcloud compute instances describe jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --format="get(tags.items)"
```

## Test from VM (Internal Test)
```powershell
gcloud compute ssh jenkins-vm --zone=us-central1-a --project=electric-autumn-474318-q3 --command="curl http://localhost:8081/"
```

## After Fix
1. Wait 1-2 minutes for firewall rule to propagate
2. Try accessing from browser: http://136.115.218.34:8081/
3. If still not working, check:
   - Application is running
   - Application is binding to 0.0.0.0:8081 (not 127.0.0.1:8081)
   - Firewall rule is active
   - VM has http-server tag

## Alternative: Use Port 8080 Instead
If port 8081 continues to have issues, you can:
1. Change application back to port 8080
2. Use existing firewall rule for port 8080
3. Or create rule for port 8080 if needed

