# ✅ GitHub Plugin and Tools Configuration

## 🎉 Status

**Plugins Enabled:**
- ✅ **GitHub plugin** - ENABLED
- ✅ **Maven Integration plugin** - ENABLED
- ✅ **Pipeline plugin** - ENABLED
- ✅ **Git plugin** - ENABLED
- ✅ **GitHub API plugin** - ENABLED

## 🛠️ Configure JDK and Maven Tools

JDK and Maven are **tools** (not plugins) that need to be configured separately.

### Quick Configuration (Web UI - 2 minutes)

1. **Access Jenkins:**
   - URL: http://136.115.218.34:8080
   - Login with admin credentials

2. **Navigate to Tool Configuration:**
   - Click: **Manage Jenkins**
   - Click: **Global Tool Configuration**
   - Or go directly to: http://136.115.218.34:8080/manage/configureTools

3. **Configure JDK:**
   - Scroll to **JDK** section
   - Click **Add JDK**
   - **Name:** `JDK-17`
   - ✅ Check **"Install automatically"**
   - **Version:** Select `17` (or latest available)
   - Click **Save**

4. **Configure Maven:**
   - Scroll to **Maven** section
   - Click **Add Maven**
   - **Name:** `Maven-3.9`
   - ✅ Check **"Install automatically"**
   - **Version:** Select `3.9.5` (or latest available)
   - Click **Save**

5. **Save Configuration:**
   - Scroll to bottom
   - Click **Save** button

### Alternative: Script Console Method

1. Go to: http://136.115.218.34:8080/script
2. Copy and paste this simplified script:

```groovy
import jenkins.model.Jenkins
import hudson.model.JDK

// Configure JDK-17
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def hasJDK17 = jdkList.any { it.name == "JDK-17" }

if (!hasJDK17) {
    def jdk17 = new JDK("JDK-17", "")
    def newJdkList = new JDK[jdkList.length + 1]
    System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
    newJdkList[jdkList.length] = jdk17
    jdkDescriptor.setInstallations(newJdkList)
    println("JDK-17 configured")
}

// Configure Maven-3.9
try {
    def mavenDesc = Jenkins.instance.getDescriptor("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
    def mavenList = mavenDesc.getInstallations()
    def hasMaven39 = mavenList.any { it.name == "Maven-3.9" }
    
    if (!hasMaven39) {
        def MavenInstallation = Class.forName("hudson.plugins.maven.MavenInstallation")
        def maven39 = MavenInstallation.newInstance("Maven-3.9", "", [])
        def newMavenList = mavenList.toList()
        newMavenList.add(maven39)
        mavenDesc.setInstallations(newMavenList.toArray())
        println("Maven-3.9 configured")
    }
} catch (Exception e) {
    println("Maven config error: " + e.message)
}

Jenkins.instance.save()
println("Configuration saved!")
```

3. Click **Run**
4. Check the output for success messages

## ✅ Verification

After configuration, verify:

1. **Check Tools:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   - Verify: **JDK-17** and **Maven-3.9** are listed

2. **Test in Pipeline:**
   - Create a test pipeline job
   - Use tools: `jdk 'JDK-17'` and `maven 'Maven-3.9'`
   - Build should succeed

## 📋 Summary

- ✅ GitHub plugin: **ENABLED**
- ✅ Maven plugin: **ENABLED**
- ✅ Pipeline plugin: **ENABLED**
- ⏳ JDK-17: **Configure via web UI** (2 minutes)
- ⏳ Maven-3.9: **Configure via web UI** (2 minutes)

## 🎯 Next Step

After tools are configured, create the Jenkins pipeline job to build and run your Hello World application!


