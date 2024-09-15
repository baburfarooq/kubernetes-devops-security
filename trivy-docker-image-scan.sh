#!/bin/bash

# Get the Docker image name from the Dockerfile
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Docker Image Name: $dockerImageName"

# Run Trivy scan with HIGH severity and capture the exit code
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImageName

# Capture the exit code from the Trivy scan
exit_code=$?
echo "Exit Code: $exit_code"

# Run Trivy scan with CRITICAL severity
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

# Capture the exit code from the second Trivy scan
exit_code=$?
echo "Exit Code: $exit_code"

# Check the exit code and provide feedback
if [ $exit_code -eq 1 ]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1
else
    echo "Image scanning passed. No vulnerabilities found"
fi
