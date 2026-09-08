# ==========================================
# Stage 1: Build the Spring Boot application
# ==========================================
# Use a Maven image with JDK 17 to compile the application
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory inside the container
WORKDIR /app

# 1. Copy pom.xml first to download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 2. Copy source code and build the executable JAR
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Lightweight runtime environment
# Use a slim JRE image without compilers to keep size small
FROM eclipse-temurin:17-jre-jammy

# 1. Install curl for the container healthcheck and clean up apt cache to save space
# 2. Create a dedicated non-root user and group ('appuser') for security
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appgroup && useradd -r -g appgroup appuser

# Set working directory for the runtime container
WORKDIR /app

# Copy ONLY the compiled fat JAR from the build stage (build tools stay behind)
COPY --from=build /app/target/hello-service.jar hello-service.jar

# Inform Docker that the container listens on port 8080
EXPOSE 8080

# Configure container healthcheck hitting the /health endpoint every 30s
# Includes a 10s start-period to allow Spring Boot to initialize before first probe
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Drop root privileges and switch to the unprivileged user
USER appuser

# Start the Spring Boot application using exec form so SIGTERM signal passes cleanly
ENTRYPOINT ["java", "-jar", "hello-service.jar"]
