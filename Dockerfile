# First stage: Build the JAR file
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /project
COPY . .
RUN mvn clean package

# Second stage: Create the runtime image
FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
COPY --from=build /project/target/*.jar /home/k8s-pipeline/app.jar
RUN chown k8s-pipeline:pipeline /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
