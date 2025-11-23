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
                    
                    # Download and setup Maven if not available (NO SUDO - using workspace)
                    if ! command -v mvn &> /dev/null; then
                        echo "Maven not found. Downloading Maven 3.9.5..."
                        cd ${WORKSPACE}
                        curl -L -o maven.tar.gz https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
                        tar -xzf maven.tar.gz
                        chmod +x ${WORKSPACE}/apache-maven-3.9.5/bin/mvn
                        echo "Maven downloaded to ${WORKSPACE}/apache-maven-3.9.5"
                    fi
                    
                    # Verify Maven
                    if [ -f ${WORKSPACE}/apache-maven-3.9.5/bin/mvn ]; then
                        echo "Maven version:"
                        ${WORKSPACE}/apache-maven-3.9.5/bin/mvn -version 2>&1 | head -3
                    else
                        echo "Maven still not available"
                    fi
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    # Use Maven from workspace if downloaded, otherwise try system Maven
                    if [ -f ${WORKSPACE}/apache-maven-3.9.5/bin/mvn ]; then
                        echo "Using downloaded Maven..."
                        ${WORKSPACE}/apache-maven-3.9.5/bin/mvn clean package -DskipTests
                    elif command -v mvn &> /dev/null; then
                        echo "Using system Maven..."
                        mvn clean package -DskipTests
                    else
                        echo "ERROR: Maven not found!"
                        exit 1
                    fi
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

