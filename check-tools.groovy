import jenkins.model.Jenkins
import hudson.model.JDK

// Check JDK installations
def jdkDesc = Jenkins.instance.getDescriptor("hudson.model.JDK")
def jdks = jdkDesc.getInstallations()
println("=== JDK Installations ===")
if (jdks.length == 0) {
    println("No JDK configured")
} else {
    jdks.each { 
        println("  - " + it.name + " (Home: " + it.home + ")")
    }
}

// Check Maven installations
try {
    def mavenDesc = Jenkins.instance.getDescriptor("hudson.plugins.maven.MavenInstallation\$MavenInstallationDescriptor")
    def mavens = mavenDesc.getInstallations()
    println("\n=== Maven Installations ===")
    if (mavens.length == 0) {
        println("No Maven configured")
    } else {
        mavens.each { 
            println("  - " + it.name + " (Home: " + it.home + ")")
        }
    }
} catch (Exception e) {
    println("\n=== Maven Installations ===")
    println("Maven plugin not available or error: " + e.message)
}

println("\n=== System Check ===")
def proc = "java -version".execute()
proc.waitFor()
println("System Java:")
proc.text.eachLine { println("  " + it) }

proc = "which mvn".execute()
proc.waitFor()
if (proc.exitValue() == 0) {
    println("\nSystem Maven found at: " + proc.text.trim())
    proc = "mvn -version".execute()
    proc.waitFor()
    proc.text.eachLine { println("  " + it) }
} else {
    println("\nSystem Maven: NOT FOUND")
}


