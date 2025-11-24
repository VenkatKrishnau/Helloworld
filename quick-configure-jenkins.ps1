# Quick Jenkins configuration using Script Console API
$JENKINS_URL = "http://136.115.218.34:8080"
$JENKINS_USER = "admin"
$JENKINS_PASSWORD = "0429d4276e2d4ace8582eb1a3afc4feb"

$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JENKINS_USER}:${JENKINS_PASSWORD}"))
$headers = @{
    Authorization = "Basic $base64Auth"
    "Content-Type" = "text/plain"
}

Write-Host "=== Quick Jenkins Configuration ===" -ForegroundColor Green

# Groovy script to configure tools
$groovyScript = @"
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tools.InstallSourceProperty
import hudson.tools.ToolProperty
import hudson.tools.ToolPropertyDescriptor
import hudson.util.DescribableList
import hudson.plugins.maven.MavenInstallation

// Configure JDK-17
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def hasJDK17 = jdkList.any { it.name == "JDK-17" }

if (!hasJDK17) {
    def jdk17 = new JDK("JDK-17", "")
    def jdkProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    def installer = new hudson.tools.JDKInstaller("17", true)
    def installSourceProp = new InstallSourceProperty([installer])
    jdkProps.add(installSourceProp)
    jdk17.setProperties(jdkProps)
    
    def newJdkList = new JDK[jdkList.length + 1]
    System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
    newJdkList[jdkList.length] = jdk17
    jdkDescriptor.setInstallations(newJdkList)
    println("JDK-17 configured")
} else {
    println("JDK-17 already configured")
}

// Configure Maven-3.9
def mavenDescriptor = Jenkins.instance.getDescriptor("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
def mavenList = mavenDescriptor.getInstallations()
def hasMaven39 = mavenList.any { it.name == "Maven-3.9" }

if (!hasMaven39) {
    def maven39 = new MavenInstallation("Maven-3.9", "", [])
    def mavenProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    def mavenInstaller = new hudson.tools.MavenInstaller("3.9.5")
    def mavenInstallSourceProp = new InstallSourceProperty([mavenInstaller])
    mavenProps.add(mavenInstallSourceProp)
    maven39.setProperties(mavenProps)
    
    def newMavenList = new MavenInstallation[mavenList.length + 1]
    System.arraycopy(mavenList, 0, newMavenList, 0, mavenList.length)
    newMavenList[mavenList.length] = maven39
    mavenDescriptor.setInstallations(newMavenList)
    println("Maven-3.9 configured")
} else {
    println("Maven-3.9 already configured")
}

Jenkins.instance.save()
println("Configuration saved successfully!")
"@

Write-Host "`nConfiguring JDK and Maven via Script Console..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$JENKINS_URL/scriptText" -Method Post -Headers $headers -Body "script=$([System.Web.HttpUtility]::UrlEncode($groovyScript))" -ErrorAction Stop
    Write-Host "✅ Configuration result:" -ForegroundColor Green
    Write-Host $response -ForegroundColor White
} catch {
    Write-Host "⚠️  Could not configure via API. Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`nPlease configure manually:" -ForegroundColor White
    Write-Host "1. Go to: $JENKINS_URL/script" -ForegroundColor Cyan
    Write-Host "2. Paste the script from configure-jenkins-tools.groovy" -ForegroundColor Cyan
    Write-Host "3. Click 'Run'" -ForegroundColor Cyan
}

Write-Host "`n=== Configuration Complete ===" -ForegroundColor Green
Write-Host "Jenkins URL: $JENKINS_URL" -ForegroundColor Cyan
Write-Host "`nNext: Install plugins via web UI and create pipeline job" -ForegroundColor Yellow


