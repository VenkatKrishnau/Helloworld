# Separate Container Setup Guide

## Architecture Change

The Spring Boot application is now running in a **separate Docker container** instead of inside the Jenkins container. This provides better isolation and follows Docker best practices.

## Architecture Overview

```
┌─────────────────────────────────────┐
│         GCP VM (jenkins-vm)         │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │   Jenkins    │  │  HelloWorld │ │
│  │  Container   │  │   Container │ │
│  │  (Port 8080) │  │  (Port 8081)│ │
│  └──────────────┘  └─────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## What Changed

### 1. New Dockerfile
- Created `Dockerfile` for the Spring Boot application
- Uses `openjdk:17-jdk-slim` base image
- Exposes port 8081

### 2. Updated Jenkinsfile
The pipeline now includes these stages:
- **Build Docker Image**: Builds the application Docker image
- **Stop Old Container**: Removes any existing container
- **Run Container**: Starts the application in a separate container
- **Test**: Verifies the application is running

### 3. Container Management
- Container name: `helloworld-app`
- Port mapping: `8081:8081`
- Restart policy: `unless-stopped`

## How It Works

1. **Jenkins Pipeline Execution:**
   - Checks out code from GitHub
   - Sets up Maven
   - Builds the Spring Boot JAR
   - Builds Docker image
   - Stops old container (if exists)
   - Runs new container
   - Tests the application

2. **Container Lifecycle:**
   - Each build creates a new container
   - Old container is stopped and removed
   - New container runs independently of Jenkins

## Accessing the Application

- **Application URL**: http://136.115.218.34:8081/
- **Health Check**: http://136.115.218.34:8081/health
- **Jenkins UI**: http://136.115.218.34:8080

## Manual Container Management

### Check Container Status
```bash
# From VM host
docker ps | grep helloworld-app

# Check logs
docker logs helloworld-app

# Check container details
docker inspect helloworld-app
```

### Stop/Start Container
```bash
# Stop container
docker stop helloworld-app

# Start container
docker start helloworld-app

# Remove container
docker rm -f helloworld-app
```

### Rebuild and Run Manually
```bash
# From Jenkins workspace or project root
docker build -t helloworld-app:latest .
docker run -d --name helloworld-app -p 8081:8081 --restart unless-stopped helloworld-app:latest
```

## Benefits of This Approach

1. **Isolation**: Application runs independently of Jenkins
2. **Scalability**: Easy to scale the application separately
3. **Resource Management**: Better resource allocation
4. **Maintainability**: Easier to update and manage
5. **Best Practices**: Follows Docker containerization best practices

## Troubleshooting

### Container Not Starting
```bash
# Check container logs
docker logs helloworld-app

# Check if port is in use
docker ps | grep 8081
netstat -tlnp | grep 8081
```

### Application Not Accessible
1. Check firewall rules allow port 8081
2. Verify container is running: `docker ps | grep helloworld-app`
3. Check container logs: `docker logs helloworld-app`
4. Test from inside container: `docker exec helloworld-app curl http://localhost:8081/`

### Build Failures
- Ensure Docker is accessible from Jenkins container
- Check Jenkins has permission to use Docker socket
- Verify Dockerfile is correct
- Check Maven build completes successfully

## Next Steps

1. **Commit and Push Changes:**
   ```bash
   git add Dockerfile Jenkinsfile .dockerignore
   git commit -m "Separate application into its own Docker container"
   git push origin main
   ```

2. **Trigger Jenkins Build:**
   - Go to Jenkins UI
   - Run the HelloWorld-Pipeline job
   - Wait for build to complete

3. **Verify Application:**
   - Access http://136.115.218.34:8081/
   - Check container is running: `docker ps | grep helloworld-app`

