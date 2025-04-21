#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found. Exiting."
  exit 1
fi

# Debug: Print loaded environment variables
echo "Loaded environment variables:"
echo "OPENAI_BASE_URL=${OPENAI_BASE_URL}"
echo "OPENAI_API_KEY=${OPENAI_API_KEY}"
echo "DEFAULT_MODEL=${DEFAULT_MODEL}"

# Build the Docker image
echo "Building the Docker image..."
./server/build-docker.sh

# Stop and remove any existing container with the same name
echo "Cleaning up existing Docker container..."
EXISTING_CONTAINER=$(docker ps -aqf "name=open-interpreter-server")
if [ -n "$EXISTING_CONTAINER" ]; then
  docker stop $EXISTING_CONTAINER
  docker rm $EXISTING_CONTAINER
fi

# Run the Docker container with environment variables from .env
echo "Starting the Docker container..."
docker run -d --name open-interpreter-server -p 8000:8000 \
  -e OPENAI_BASE_URL="${OPENAI_BASE_URL:-}" \
  -e OPENAI_API_KEY="${OPENAI_API_KEY:-}" \
  -e DEFAULT_MODEL="${DEFAULT_MODEL:-}" \
  open-interpreter-server
CONTAINER_ID=$(docker ps -qf "name=open-interpreter-server")

# Wait for the server to start
sleep 10

# Test the server with curl
echo "Testing /chat endpoint with curl..."
CHAT_RESPONSE=$(curl -s -G "http://127.0.0.1:8000/chat" --data-urlencode "message=Hello")

if [[ $CHAT_RESPONSE == *"data:"* ]]; then
  echo "Chat endpoint is working!"
else
  echo "Chat endpoint test failed!"
  docker logs open-interpreter-server
  docker stop $CONTAINER_ID
  docker rm $CONTAINER_ID
  exit 1
fi

# Test the server with a JavaScript client
echo "Testing /history endpoint with a JavaScript client..."
cat <<EOF > test_client.js
const http = require('http');

http.get('http://127.0.0.1:8000/history', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log('History Response:', data);
    process.exit(0);
  });
}).on('error', (err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
EOF

node test_client.js
JS_EXIT_CODE=$?

# Clean up
rm test_client.js
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

if [[ $JS_EXIT_CODE -eq 0 ]]; then
  echo "History endpoint is working!"
  exit 0
else
  echo "History endpoint test failed!"
  exit 1
fi