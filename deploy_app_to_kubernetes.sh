#!/usr/bin/env bash

# This runs a Docker container on Kubernetes

# Assumes that an image is built and tagged via `upload_docker.sh`
app=practice-flask-app
dockerpath=laviniak/${app}

# Step 1
# Run the Docker container with kubernetes
kubectl run ${app} --image=$dockerpath --port=80

# Step 2:
# List kubernetes pods
kubectl get pods

# Step 3:
# Forward the container port to a host
kubectl port-forward deployment.apps/${app} 8000:80
