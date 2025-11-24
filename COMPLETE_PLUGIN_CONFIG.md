# ✅ Complete Jenkins Plugin Configuration

## 🎯 Quick Steps to Configure Plugins

### Access Jenkins
- **URL:** http://136.115.218.34:8080
- **Password:** `0429d4276e2d4ace8582eb1a3afc4feb`

### Step 1: Install Plugins (5 minutes)

1. **Access Jenkins Web UI:**
   - Open: http://136.115.218.34:8080
   - Enter password and complete initial setup

2. **Install Plugins:**
   - Go to: **Manage Jenkins** → **Plugins** → **Available**
   - Search and install:
     - **GitHub plugin** (search: "github")
     - **Maven Integration plugin** (search: "maven")  
     - **Pipeline plugin** (search: "workflow-aggregator")
   - Click "Install without restart" or "Download now and install after restart"
   - Wait for installation to complete

### Step 2: Configure Tools (2 minutes)

1. **Go to:** **Manage Jenkins** → **Global Tool Configuration**

2. **Configure JDK:**
   - Under "JDK", click "Add JDK"
   - Name: `JDK-17`
   - ✅ Check "Install automatically"
   - Version: Select `17` (or latest)
   - Click "Save"

3. **Configure Maven:**
   - Under "Maven", click "Add Maven"
   - Name: `Maven-3.9`
   - ✅ Check "Install automatically"
   - Version: Select `3.9.5` (or latest)
   - Click "Save"

4. **Save Configuration:**
   - Click "Save" at the bottom of the page

### Step 3: Verify Configuration

1. **Verify Plugins:**
   - Go to: **Manage Jenkins** → **Plugins** → **Installed**
   - Confirm: GitHub plugin, Maven Integration plugin, Pipeline plugin are listed

2. **Verify Tools:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   - Confirm: JDK-17 and Maven-3.9 are listed

## ✅ Configuration Complete!

After completing these steps, you're ready to create the Jenkins pipeline job.

## 📋 Next: Create Pipeline Job

See `CREATE_PIPELINE_JOB.md` for instructions on creating the pipeline job.


