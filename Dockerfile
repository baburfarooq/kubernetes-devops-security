FROM adoptopenjdk/openjdk8:alpine-slim

# Expose port 8080
EXPOSE 8080

# Define a build argument for the JAR file location
ARG JAR_FILE=target/*.jar

# Create a new user and group, and set up the user
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline

# Copy the JAR file into the container
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar

# Change ownership of the JAR file to the non-root user
RUN chown k8s-pipeline:pipeline /home/k8s-pipeline/app.jar

# Switch to the non-root user
USER k8s-pipeline

# Set the entrypoint for the container
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
