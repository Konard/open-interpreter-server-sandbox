#!/bin/bash

# Set the image name
IMAGE_NAME="open-interpreter-server"

# Navigate to the directory containing the Dockerfile
cd "$(dirname "$0")"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Print success message
echo "Docker image '$IMAGE_NAME' built successfully."