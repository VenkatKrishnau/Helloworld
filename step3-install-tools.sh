#!/bin/bash
# Install JDK 17 and Maven 3.9.5 in Jenkins container
sudo docker exec -u root jenkins bash -c "apt-get update && apt-get install -y openjdk-17-jdk-headless || apt-get install -y default-jdk && curl -L https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz -o /tmp/maven.tar.gz && tar -xzf /tmp/maven.tar.gz -C /opt && ln -s /opt/apache-maven-3.9.5 /opt/maven && rm /tmp/maven.tar.gz && echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /var/jenkins_home/.profile && echo 'export MAVEN_HOME=/opt/maven' >> /var/jenkins_home/.profile && echo 'export PATH=\$MAVEN_HOME/bin:\$PATH' >> /var/jenkins_home/.profile"

