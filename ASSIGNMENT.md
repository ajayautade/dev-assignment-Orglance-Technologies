# DevOps Assignment — Containerize a Spring Boot Service

## Overview

This repository contains a minimal Spring Boot "hello world" REST service.
Your task is to containerize it and prepare it for deployment.

## The Service

A Spring Boot 3 app (Java 17) exposing:

| Endpoint            | Method | Description                                   |
| ------------------- | ------ | --------------------------------------------- |
| `/`                 | GET    | Returns `{ "message": "Hello, World!" }`      |
| `/health`           | GET    | Returns `{ "status": "UP" }`                  |
| `/actuator/health`  | GET    | Spring Boot actuator health endpoint          |

Default port: **8080**

Configurable via environment variables:

- `GREETING` — greeting word (default: `Hello`)
- `NAME` — name to greet (default: `World`)
- `SERVER_PORT` — override server port (default: `8080`)

### Build & run locally (without Docker)

```bash
./mvnw clean package        # or: mvn clean package
java -jar target/hello-service.jar
curl http://localhost:8080/
```

---

## Your Assignment

You need to deliver **two artifacts** so this service can be built and deployed with Docker:

### 1. `Dockerfile`

Build a container image for the service. Requirements:

- Use a **multi-stage build**: one stage to compile the JAR with Maven, one stage to run it.
- The final runtime image should be based on a **slim JRE** (not a full JDK) to keep the image small.
- Run the app as a **non-root user**.
- Expose port `8080`.
- Include a `HEALTHCHECK` instruction that hits `/health`.
- The image should start the service with `java -jar` as the container's entrypoint.

### 2. `docker-compose.yml`

Compose file that runs the service. Requirements:

- Build from the local `Dockerfile`.
- Map host port `8080` to container port `8080`.
- Pass `GREETING` and `NAME` as environment variables (feel free to hardcode values or read from an `.env` file).
- Add a `healthcheck` using the `/health` endpoint.
- Set `restart: unless-stopped`.

### Verification

We should be able to clone the repo and run:

```bash
docker compose up --build
curl http://localhost:8080/
# => {"message":"Hello, <NAME>!"}
```

## Submission

- Fork this repo (or create your own) and push your `Dockerfile` and `docker-compose.yml`.
- Include a short note in the PR / email describing:
  - Final image size and how you kept it small.
  - Any tradeoffs or things you would improve given more time.

## Evaluation Criteria

- Image is small and uses a multi-stage build correctly.
- Container runs as a non-root user.
- Compose file is clean, well-structured, and works out of the box.
- Healthchecks are wired up in both the Dockerfile and Compose file.
- Sensible defaults; secrets/config not baked into the image.
