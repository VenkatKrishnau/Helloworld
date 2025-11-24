#!/bin/bash
# Complete Jenkins setup with JDK 17 and Maven 3.9

# Step 1: Delete existing Jenkins
echo "=== Step 1: Deleting existing Jenkins ==="
sudo docker stop jenkins 2>/dev/null || true
sudo docker rm jenkins 2>/dev/null || true

# Step 2: Create Dockerfile
echo "=== Step 2: Creating Dockerfile ==="
cat > /tmp/Dockerfile << 'DOCKERFILE_EOF'
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 1 && \
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
RUN curl -L https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -o /tmp/maven.tar.gz && \
    tar -xzf /tmp/maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.5 /opt/maven && \
    rm /tmp/maven.tar.gz
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH
USER jenkins
DOCKERFILE_EOF

# Step 3: Build image
echo "=== Step 3: Building Jenkins image with JDK 17 and Maven 3.9.5 ==="
cd /tmp
sudo docker build -t jenkins-with-tools:latest .

# Step 4: Deploy Jenkins
echo "=== Step 4: Deploying Jenkins container ==="
sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins-with-tools:latest

echo "=== Jenkins deployed! ==="
echo "Waiting 30 seconds for Jenkins to start..."
sleep 30

# Get password
echo "=== Jenkins Initial Password ==="
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo ""
echo "Jenkins URL: http://$(curl -s ifconfig.me):8080"

