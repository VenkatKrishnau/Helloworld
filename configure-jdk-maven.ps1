# Configure JDK and Maven tools in Jenkins
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"

Write-Host "=== Configuring JDK and Maven Tools ===" -ForegroundColor Green

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_PASSWORD}"))
$headers = @{
    Authorization = "Basic $base64Auth"
    "Content-Type" = "text/plain"
}

# Groovy script to configure tools
$groovyScript = @"
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tools.*
import hudson.util.DescribableList

// Configure JDK-17
println("Configuring JDK-17...")
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def hasJDK17 = jdkList.any { it.name == "JDK-17" }

if (!hasJDK17) {
    def jdk17 = new JDK("JDK-17", "")
    def jdkProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    
    try {
        // Try to use auto-installer
        def installerClass = Class.forName("hudson.tools.JDKInstaller")
        def installer = installerClass.newInstance("17", true)
        def installSourceProp = new InstallSourceProperty([installer])
        jdkProps.add(installSourceProp)
        jdk17.setProperties(jdkProps)
        println("JDK-17 configured with auto-installer")
    } catch (Exception e) {
        // If auto-installer not available, configure manually
        jdk17.setProperties(jdkProps)
        println("JDK-17 configured (manual installation required)")
    }
    
    def newJdkList = new JDK[jdkList.length + 1]
    System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
    newJdkList[jdkList.length] = jdk17
    jdkDescriptor.setInstallations(newJdkList)
    println("✅ JDK-17 added successfully")
} else {
    println("✅ JDK-17 already configured")
}

// Configure Maven-3.9
println("Configuring Maven-3.9...")
try {
    def mavenDescriptorClass = Class.forName("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
    def mavenDescriptor = Jenkins.instance.getDescriptor(mavenDescriptorClass)
    def mavenList = mavenDescriptor.getInstallations()
    def hasMaven39 = mavenList.any { it.name == "Maven-3.9" }
    
    if (!hasMaven39) {
        def MavenInstallation = Class.forName("hudson.plugins.maven.MavenInstallation")
        def maven39 = MavenInstallation.newInstance("Maven-3.9", "", [])
        
        def mavenProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
        try {
            def MavenInstaller = Class.forName("hudson.tools.MavenInstaller")
            def mavenInstaller = MavenInstaller.newInstance("3.9.5")
            def mavenInstallSourceProp = new InstallSourceProperty([mavenInstaller])
            mavenProps.add(mavenInstallSourceProp)
            maven39.setProperties(mavenProps)
            println("Maven-3.9 configured with auto-installer")
        } catch (Exception e) {
            maven39.setProperties(mavenProps)
            println("Maven-3.9 configured (manual installation required)")
        }
        
        def newMavenList = mavenList.toList()
        newMavenList.add(maven39)
        mavenDescriptor.setInstallations(newMavenList.toArray())
        println("✅ Maven-3.9 added successfully")
    } else {
        println("✅ Maven-3.9 already configured")
    }
} catch (Exception e) {
    println("⚠️  Maven configuration error: " + e.message)
    println("Please configure Maven via web UI")
}

Jenkins.instance.save()
println("✅ Configuration saved!")
"@

Write-Host "`nConfiguring tools via Script Console..." -ForegroundColor Yellow

try {
    $scriptEncoded = [System.Web.HttpUtility]::UrlEncode($groovyScript)
    $body = "script=$scriptEncoded"
    
    $response = Invoke-RestMethod -Uri "$JENKINS_URL/scriptText" -Method Post -Headers $headers -Body $body -ErrorAction Stop
    Write-Host "`n✅ Configuration Result:" -ForegroundColor Green
    Write-Host $response -ForegroundColor White
} catch {
    Write-Host "`n⚠️  API configuration failed. Using alternative method..." -ForegroundColor Yellow
    
    # Try via CLI
    Write-Host "`nTrying via Jenkins CLI..." -ForegroundColor Cyan
    if (Test-Path "jenkins-cli.jar") {
        $scriptFile = "configure-tools-temp.groovy"
        $groovyScript | Out-File -FilePath $scriptFile -Encoding UTF8
        
        try {
            $result = Get-Content $scriptFile | java -jar jenkins-cli.jar -s $JENKINS_URL -auth "$JENKINS_USER`:$JENKINS_PASSWORD" groovy = 2>&1
            Write-Host $result
            Remove-Item $scriptFile -ErrorAction SilentlyContinue
        } catch {
            Write-Host "`n⚠️  CLI method also failed. Please configure manually:" -ForegroundColor Yellow
            Write-Host "1. Go to: $JENKINS_URL/manage/configureTools" -ForegroundColor White
            Write-Host "2. Add JDK-17 and Maven-3.9" -ForegroundColor White
        }
    } else {
        Write-Host "`nPlease configure tools manually via web UI:" -ForegroundColor Yellow
        Write-Host "1. Go to: $JENKINS_URL/manage/configureTools" -ForegroundColor White
        Write-Host "2. Add JDK: Name=JDK-17, Install automatically, Version=17" -ForegroundColor White
        Write-Host "3. Add Maven: Name=Maven-3.9, Install automatically, Version=3.9.5" -ForegroundColor White
    }
}

Write-Host "`n=== Configuration Complete ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan


