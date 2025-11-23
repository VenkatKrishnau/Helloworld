pipeline {
    agent any
    
    // Tools section removed - using system Java/Maven
    // To use configured tools, add:
    // tools {
    //     maven 'Maven-3.9'
    //     jdk 'JDK-17'
    // }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/venkatkrishnau/Helloworld.git'
            }
        }
        
        stage('Setup Tools') {
            steps {
                sh '''
                    echo "=== Setting up build tools ==="
                    
                    # Check Java
                    if command -v java &> /dev/null; then
                        echo "Java found:"
                        java -version 2>&1 | head -3
                    else
                        echo "Java not found in PATH"
                    fi
                    
                    # Download and setup Maven if not available
                    if ! command -v mvn &> /dev/null; then
                        echo "Maven not found. Downloading Maven 3.9.5..."
                        cd /tmp
                        curl -L -o maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
                        tar -xzf maven.tar.gz
                        export PATH=/tmp/apache-maven-3.9.5/bin:$PATH
                        export MAVEN_HOME=/tmp/apache-maven-3.9.5
                        echo "Maven downloaded and configured"
                    fi
                    
                    # Verify Maven
                    echo "Maven version:"
                    mvn -version 2>&1 | head -3
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    # Ensure Maven is in PATH
                    if [ -d /tmp/apache-maven-3.9.5 ]; then
                        export PATH=/tmp/apache-maven-3.9.5/bin:$PATH
                        export MAVEN_HOME=/tmp/apache-maven-3.9.5
                    fi
                    
                    # Build the application
                    mvn clean package -DskipTests
                '''
            }
        }
        
        stage('Run') {
            steps {
                sh '''
                    pkill -f helloworld || true
                    nohup java -jar target/helloworld-1.0.0.jar > app.log 2>&1 &
                    sleep 5
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    sleep 3
                    curl -f http://localhost:8080/ || exit 1
                    curl -f http://localhost:8080/health || exit 1
                '''
            }
        }
    }
    
    post {
        always {
            sh 'cat app.log || true'
        }
    }
}

