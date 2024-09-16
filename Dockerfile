# Stage 1: Build
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Runtime
FROM adoptopenjdk/openjdk8:alpine-slim
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
USER k8s-pipeline
EXPOSE 8080
COPY --from=build /app/target/*.jar /home/k8s-pipeline/app.jar
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
