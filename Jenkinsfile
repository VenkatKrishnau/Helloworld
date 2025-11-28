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
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "=== Building Docker Image ==="
                    docker build -t helloworld-app:latest .
                    docker images | grep helloworld-app
                '''
            }
        }
        
        stage('Stop Old Container') {
            steps {
                sh '''
                    echo "=== Stopping Old Container (if exists) ==="
                    docker stop helloworld-app || true
                    docker rm helloworld-app || true
                '''
            }
        }
        
        stage('Run Container') {
            steps {
                sh '''
                    echo "=== Starting Application Container ==="
                    docker run -d \
                        --name helloworld-app \
                        -p 8081:8081 \
                        --restart unless-stopped \
                        helloworld-app:latest
                    
                    echo "Waiting for application to start..."
                    sleep 10
                    
                    echo "Container status:"
                    docker ps | grep helloworld-app
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    echo "=== Testing Application ==="
                    sleep 5
                    
                    # Test from host (Jenkins container can access host Docker)
                    curl -f http://localhost:8081/ || exit 1
                    curl -f http://localhost:8081/health || exit 1
                    
                    echo "✅ Application is running and responding!"
                '''
            }
        }
    }
    
    post {
        always {
            sh '''
                echo "=== Container Logs ==="
                docker logs --tail 50 helloworld-app || echo "Container not found or not running"
                
                echo ""
                echo "=== Container Status ==="
                docker ps -a | grep helloworld-app || echo "No helloworld-app container found"
            '''
        }
    }
}

