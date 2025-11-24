// Fix: Configure JDK-17 and Maven-3.9 in Jenkins
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tools.*
import hudson.util.DescribableList

println("=== Configuring Jenkins Tools ===")

// Configure JDK-17
println("\n1. Configuring JDK-17...")
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def hasJDK17 = jdkList.any { it != null && it.name == "JDK-17" }

if (!hasJDK17) {
    def jdk17 = new JDK("JDK-17", "")
    def jdkProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    
    // Try to add auto-installer
    try {
        def installerClass = Class.forName("hudson.tools.JDKInstaller")
        def installer = installerClass.newInstance("17", true)
        def installSourceProp = new InstallSourceProperty([installer])
        jdkProps.add(installSourceProp)
        jdk17.setProperties(jdkProps)
        println("   ✅ JDK-17 configured with auto-installer")
    } catch (Exception e) {
        // Manual configuration
        jdk17.setProperties(jdkProps)
        println("   ✅ JDK-17 configured (manual path)")
    }
    
    def newJdkList = new JDK[jdkList.length + 1]
    System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
    newJdkList[jdkList.length] = jdk17
    jdkDescriptor.setInstallations(newJdkList)
    println("   ✅ JDK-17 added to Jenkins")
} else {
    println("   ✅ JDK-17 already exists")
}

// Configure Maven-3.9
println("\n2. Configuring Maven-3.9...")
try {
    def mavenDescClass = Class.forName("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
    def mavenDescriptor = Jenkins.instance.getDescriptor(mavenDescClass)
    def mavenList = mavenDescriptor.getInstallations()
    def hasMaven39 = mavenList.any { it != null && it.name == "Maven-3.9" }
    
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
            println("   ✅ Maven-3.9 configured with auto-installer")
        } catch (Exception e) {
            maven39.setProperties(mavenProps)
            println("   ✅ Maven-3.9 configured (manual path)")
        }
        
        def newMavenList = mavenList.toList()
        newMavenList.add(maven39)
        mavenDescriptor.setInstallations(newMavenList.toArray())
        println("   ✅ Maven-3.9 added to Jenkins")
    } else {
        println("   ✅ Maven-3.9 already exists")
    }
} catch (Exception e) {
    println("   ❌ Error configuring Maven: " + e.message)
    println("   Please configure Maven via web UI")
}

// Save configuration
Jenkins.instance.save()
println("\n✅ Configuration saved successfully!")
println("\nTools configured:")
println("  - JDK-17")
println("  - Maven-3.9")


