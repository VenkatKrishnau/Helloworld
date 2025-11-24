# Quick Fix: JDK-17 and Maven-3.9 Not Configured

## 🔍 Problem

**Error Message:**
```
Tool type "maven" does not have an install of "Maven-3.9" configured
Tool type "jdk" does not have an install of "JDK-17" configured
```

**Cause:** The Jenkinsfile references tools that aren't configured in Jenkins.

## ✅ Solution Options

### Option 1: Configure Tools in Jenkins (Recommended)

**Steps (2 minutes):**

1. **Go to:** http://136.115.218.34:8080/manage/configureTools

2. **Add JDK:**
   - Click "Add JDK"
   - **Name:** `JDK-17` (exact match required)
   - ✅ Check "Install automatically"
   - **Version:** `17`
   - Save

3. **Add Maven:**
   - Click "Add Maven"
   - **Name:** `Maven-3.9` (exact match required)
   - ✅ Check "Install automatically"
   - **Version:** `3.9.5`
   - Save

4. **Click "Save"** at bottom

5. **Rebuild job:** http://136.115.218.34:8080/job/HelloWorld-Pipeline

### Option 2: Update Jenkinsfile (Quick Fix)

If you can't configure tools right now, update the Jenkinsfile to remove the tools section:

1. **Update Jenkinsfile in GitHub:**
   - Remove or comment out the `tools` section
   - Use system Java/Maven instead

2. **Or use the fixed version:**
   - Copy `Jenkinsfile-fixed` content
   - Update in GitHub repository
   - Rebuild job

### Option 3: Install Maven on Jenkins VM

If Jenkins agent has Maven installed, you can use it directly:

```groovy
pipeline {
    agent any
    // Remove tools section
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'  // Uses system Maven
            }
        }
    }
}
```

## 🎯 Recommended: Configure Tools (Option 1)

This is the best long-term solution. It takes 2 minutes and ensures consistent builds.

**Direct Link:** http://136.115.218.34:8080/manage/configureTools

## ✅ After Fixing

Once tools are configured or Jenkinsfile is updated:
1. Rebuild the job
2. Check console output
3. Build should succeed


