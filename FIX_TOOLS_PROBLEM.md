# Fix: JDK-17 and Maven-3.9 Not Configured

## 🔍 Problem Understanding

**Error:**
```
Tool type "maven" does not have an install of "Maven-3.9" configured
Tool type "jdk" does not have an install of "JDK-17" configured
```

**Root Cause:**
The Jenkinsfile references `JDK-17` and `Maven-3.9` in the `tools` section, but these tools are not configured in Jenkins Global Tool Configuration.

## ✅ Solution: Configure Tools in Jenkins

### Method 1: Via Web UI (Recommended - 2 minutes)

1. **Access Jenkins:**
   - Go to: http://136.115.218.34:8080
   - Login with admin credentials

2. **Configure JDK:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   - Scroll to **JDK** section
   - Click **"Add JDK"**
   - **Name:** `JDK-17` (must match exactly)
   - ✅ Check **"Install automatically"**
   - **Version:** Select `17` (or latest)
   - Click **Save**

3. **Configure Maven:**
   - Scroll to **Maven** section
   - Click **"Add Maven"**
   - **Name:** `Maven-3.9` (must match exactly)
   - ✅ Check **"Install automatically"**
   - **Version:** Select `3.9.5` (or latest)
   - Click **Save**

4. **Save Configuration:**
   - Scroll to bottom
   - Click **"Save"** button

### Method 2: Via Script Console

1. Go to: http://136.115.218.34:8080/script
2. Copy and paste the script from `fix-jenkins-tools.groovy`
3. Click **"Run"**
4. Check output for success messages

### Method 3: Alternative - Update Jenkinsfile (Quick Fix)

If you can't configure tools right now, you can temporarily modify the Jenkinsfile to use system tools:

```groovy
pipeline {
    agent any
    
    // Remove tools section or use withEnv
    environment {
        JAVA_HOME = tool 'JDK-17'  // Only if configured
        MAVEN_HOME = tool 'Maven-3.9'  // Only if configured
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/venkatkrishnau/Helloworld.git'
            }
        }
        
        stage('Build') {
            steps {
                // Use system Maven if available
                sh 'mvn clean package || /usr/bin/mvn clean package'
            }
        }
        
        // ... rest of pipeline
    }
}
```

**Or remove tools section entirely and use system Java/Maven:**
```groovy
pipeline {
    agent any
    
    // Remove tools section - use system Java/Maven
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/venkatkrishnau/Helloworld.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        // ... rest
    }
}
```

## ✅ Verification

After configuring tools:

1. **Verify tools are configured:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   - Verify: `JDK-17` and `Maven-3.9` are listed

2. **Rebuild the job:**
   - Go to: http://136.115.218.34:8080/job/HelloWorld-Pipeline
   - Click **"Build Now"**
   - The error should be resolved

## 🎯 Recommended Action

**Best approach:** Configure tools via Web UI (Method 1) - it's the most reliable and takes only 2 minutes.

The tool names in Jenkins **must match exactly** what's in the Jenkinsfile:
- `JDK-17` (not `jdk-17` or `JDK17`)
- `Maven-3.9` (not `maven-3.9` or `Maven39`)


