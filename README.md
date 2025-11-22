# Hello World Spring Boot Application

A simple Spring Boot application that demonstrates a basic REST API.

## Features

- Spring Boot 3.2.0
- Java 17
- RESTful endpoints

## Endpoints

- `GET /` - Returns "Hello World from Spring Boot!"
- `GET /health` - Returns health status

## Running the Application

### Prerequisites
- Java 17 or higher
- Maven 3.6+

### Build and Run

```bash
mvn clean install
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### Test the Application

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

## Building for Production

```bash
mvn clean package
java -jar target/helloworld-1.0.0.jar
```

## Note

If you encounter any XML parsing issues with `pom.xml`, run the fix script:
- Windows: `.\fix-pom.ps1`
- Linux/Mac: `chmod +x fix-pom.sh && ./fix-pom.sh`

