// Groovy script to configure Jenkins tools (JDK and Maven)
// This script can be executed via Jenkins Script Console

import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tools.InstallSourceProperty
import hudson.tools.ToolProperty
import hudson.tools.ToolPropertyDescriptor
import hudson.tools.ToolInstallation
import hudson.util.DescribableList
import jenkins.plugins.nodejs.tools.NodeJSInstallation
import hudson.plugins.maven.MavenInstallation
import hudson.plugins.maven.MavenInstallation.MavenInstallationDescriptor

// Configure JDK
println("Configuring JDK-17...")
def jdkDescriptor = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdkList = jdkDescriptor.getInstallations()
def jdk17 = new JDK("JDK-17", "")

// Add auto-installer for JDK
def jdkProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
def installer = new hudson.tools.JDKInstaller("17", true)
def installSourceProp = new InstallSourceProperty([installer])
jdkProps.add(installSourceProp)
jdk17.setProperties(jdkProps)

// Add JDK to list
def newJdkList = new JDK[jdkList.length + 1]
System.arraycopy(jdkList, 0, newJdkList, 0, jdkList.length)
newJdkList[jdkList.length] = jdk17
jdkDescriptor.setInstallations(newJdkList)
println("✅ JDK-17 configured")

// Configure Maven
println("Configuring Maven-3.9...")
def mavenDescriptor = Jenkins.instance.getDescriptor("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
def mavenList = mavenDescriptor.getInstallations()
def maven39 = new MavenInstallation("Maven-3.9", "", [])

// Add auto-installer for Maven
def mavenProps = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
def mavenInstaller = new hudson.tools.MavenInstaller("3.9.5")
def mavenInstallSourceProp = new InstallSourceProperty([mavenInstaller])
mavenProps.add(mavenInstallSourceProp)
maven39.setProperties(mavenProps)

// Add Maven to list
def newMavenList = new MavenInstallation[mavenList.length + 1]
System.arraycopy(mavenList, 0, newMavenList, 0, mavenList.length)
newMavenList[mavenList.length] = maven39
mavenDescriptor.setInstallations(newMavenList)
println("✅ Maven-3.9 configured")

// Save configuration
Jenkins.instance.save()
println("✅ Configuration saved!")


