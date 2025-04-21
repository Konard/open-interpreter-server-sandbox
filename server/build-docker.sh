#!/bin/bash
# filepath: /Users/konard/Code/konard/open-interpreter-server-sandbox/server/build-docker.sh

# Set the image name
IMAGE_NAME="open-interpreter-server"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Print success message
echo "Docker image '$IMAGE_NAME' built successfully."