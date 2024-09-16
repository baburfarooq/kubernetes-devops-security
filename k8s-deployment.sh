#!/bin/bash
# k8s-deployment.sh

# Replace placeholder in YAML file with the actual image name
sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml

# Check if the deployment exists
kubectl -n default get deployment ${deploymentName} > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Deployment ${deploymentName} doesn't exist"
    kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "Deployment ${deploymentName} exists"
    echo "Image name - ${imageName}"
    kubectl -n default set image deployment/${deploymentName} ${containerName}=${imageName} --record=true
fi
