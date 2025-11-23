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
                    # Install Java 17 if not available
                    if ! command -v java &> /dev/null || ! java -version 2>&1 | grep -q "17"; then
                        echo "Installing Java 17..."
                        sudo apt-get update -qq
                        sudo apt-get install -y openjdk-17-jdk || echo "Java 17 installation may require root"
                        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 || export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
                        export PATH=$JAVA_HOME/bin:$PATH
                    fi
                    
                    # Install Maven if not available
                    if ! command -v mvn &> /dev/null; then
                        echo "Installing Maven..."
                        sudo apt-get install -y maven || echo "Maven installation may require root"
                    fi
                    
                    # Verify installations
                    echo "Java version:"
                    java -version 2>&1 || echo "Java not found"
                    echo "Maven version:"
                    mvn -version 2>&1 || echo "Maven not found"
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    # Use system Maven or try to find it
                    if command -v mvn &> /dev/null; then
                        mvn clean package
                    elif [ -f /usr/bin/mvn ]; then
                        /usr/bin/mvn clean package
                    else
                        echo "Maven not found. Installing..."
                        # Try to download and use Maven wrapper or install
                        curl -s https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz | tar -xz
                        export PATH=$PWD/apache-maven-3.9.5/bin:$PATH
                        mvn clean package
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

