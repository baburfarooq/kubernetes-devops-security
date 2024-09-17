#!/bin/bash

# Sleep for 60 seconds to wait for deployment status
sleep 60s

# Check the deployment rollout status
kubectl -n default rollout status deploy ${deploymentName} --timeout=5m

# Capture the exit status of the rollout status command
status=$?

if [[ $status -ne 0 ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1
else
    echo "Deployment ${deploymentName} Rollout is Successful"
fi
