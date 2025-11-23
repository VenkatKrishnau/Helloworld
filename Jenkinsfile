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
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
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

