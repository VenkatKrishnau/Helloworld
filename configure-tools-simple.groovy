// Simplified script to configure JDK and Maven
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tools.*
import hudson.util.DescribableList

// Configure JDK-17
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def hasJDK17 = jdkList.any { it.name == "JDK-17" }

if (!hasJDK17) {
    def jdk17 = new JDK("JDK-17", "")
    def jdkProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    try {
        def installer = new JDKInstaller("17", true)
        def installSourceProp = new InstallSourceProperty([installer])
        jdkProps.add(installSourceProp)
        jdk17.setProperties(jdkProps)
    } catch (Exception e) {
        println("Note: Auto-installer not available, using manual path")
    }
    
    def newJdkList = new JDK[jdkList.length + 1]
    System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
    newJdkList[jdkList.length] = jdk17
    jdkDescriptor.setInstallations(newJdkList)
    println("JDK-17 configured")
} else {
    println("JDK-17 already configured")
}

// Configure Maven-3.9
try {
    def mavenDescriptor = Jenkins.instance.getDescriptor("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
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
        } catch (Exception e) {
            println("Note: Maven auto-installer not available")
        }
        
        def newMavenList = mavenList.toList()
        newMavenList.add(maven39)
        mavenDescriptor.setInstallations(newMavenList.toArray())
        println("Maven-3.9 configured")
    } else {
        println("Maven-3.9 already configured")
    }
} catch (Exception e) {
    println("Maven configuration requires Maven plugin. Error: " + e.message)
}

Jenkins.instance.save()
println("Configuration saved!")


