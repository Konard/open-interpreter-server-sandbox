#!/bin/bash

# Build the Docker image
echo "Building the Docker image..."
./server/build-docker.sh

# Run the Docker container
echo "Starting the Docker container..."
docker run -d --name open-interpreter-server -p 8000:8000 open-interpreter-server
CONTAINER_ID=$(docker ps -qf "name=open-interpreter-server")

# Wait for the server to start
sleep 3

# Test the server with curl
echo "Testing /chat endpoint with curl..."
CHAT_RESPONSE=$(curl -s -G "http://127.0.0.1:8000/chat" --data-urlencode "message=Hello")

if [[ $CHAT_RESPONSE == *"data:"* ]]; then
  echo "Chat endpoint is working!"
else
  echo "Chat endpoint test failed!"
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