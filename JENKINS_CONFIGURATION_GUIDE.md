# Jenkins Plugin and Tool Configuration Guide

## ✅ Current Status
- Jenkins is running at: http://136.115.218.34:8080
- Initial admin password: `0429d4276e2d4ace8582eb1a3afc4feb`

## 🎯 Quick Configuration (Web UI Method)

### Step 1: Access Jenkins
1. Open: http://136.115.218.34:8080
2. Enter password: `0429d4276e2d4ace8582eb1a3afc4feb`
3. Click "Continue"
4. Install suggested plugins (wait for completion)
5. Create admin user or skip

### Step 2: Install Required Plugins
1. Go to: **Manage Jenkins** → **Plugins** → **Available**
2. Search and install:
   - ✅ **GitHub plugin** (search: "github")
   - ✅ **Maven Integration plugin** (search: "maven")
   - ✅ **Pipeline plugin** (search: "workflow-aggregator" or "pipeline")
3. Click "Install without restart" or "Download now and install after restart"
4. If prompted, restart Jenkins

### Step 3: Configure Tools
1. Go to: **Manage Jenkins** → **Global Tool Configuration**
2. **JDK Configuration:**
   - Under "JDK", click "Add JDK"
   - Name: `JDK-17`
   - Check ✅ "Install automatically"
   - Version: Select `17` (or latest available)
   - Click "Save"
3. **Maven Configuration:**
   - Under "Maven", click "Add Maven"
   - Name: `Maven-3.9`
   - Check ✅ "Install automatically"
   - Version: Select `3.9.5` (or latest available)
   - Click "Save"
4. Click "Save" at the bottom

## 🤖 Automated Configuration (Script Method)

### Option A: Using Jenkins CLI

```powershell
# Install plugins
java -jar jenkins-cli.jar -s http://136.115.218.34:8080 -auth admin:0429d4276e2d4ace8582eb1a3afc4feb install-plugin github maven-plugin workflow-aggregator -deploy

# Restart Jenkins (if needed)
java -jar jenkins-cli.jar -s http://136.115.218.34:8080 -auth admin:0429d4276e2d4ace8582eb1a3afc4feb restart
```

### Option B: Using Script Console

1. Go to: **Manage Jenkins** → **Script Console**
2. Paste and run the script from `configure-jenkins-tools.groovy`
3. This will configure JDK-17 and Maven-3.9 automatically

## ✅ Verification

After configuration, verify:

1. **Plugins installed:**
   - Go to: **Manage Jenkins** → **Plugins** → **Installed**
   - Verify: GitHub plugin, Maven Integration plugin, Pipeline plugin

2. **Tools configured:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   - Verify: JDK-17 and Maven-3.9 are listed

## 📋 Next Step: Create Pipeline Job

After plugins and tools are configured:
1. Create new Pipeline job
2. Point to: https://github.com/venkatkrishnau/Helloworld.git
3. Use Jenkinsfile from repository

## 🔧 Troubleshooting

**Plugins not installing:**
- Wait for Jenkins to fully initialize (2-3 minutes after first access)
- Check internet connectivity from VM
- Try installing one plugin at a time

**Tools not appearing:**
- Ensure plugins are installed first
- Restart Jenkins if needed
- Check tool installation logs in Jenkins

**Access issues:**
- Verify firewall allows port 8080
- Check VM is running: `gcloud compute instances list`
- Verify Jenkins container: `sudo docker ps` on VM


