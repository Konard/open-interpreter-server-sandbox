#!/bin/bash

# Install necessary Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt || pip install fastapi uvicorn

# Install necessary Node.js dependencies
echo "Installing Node.js dependencies..."
npm install node-fetch dotenv || npm install

# Start the FastAPI server in the background
echo "Starting the FastAPI server..."
python3 -m uvicorn server.server:app --host 127.0.0.1 --port 8000 &
SERVER_PID=$!

# Wait for the server to start
sleep 3

# Test the server with curl
echo "Testing /chat endpoint with curl..."
CHAT_RESPONSE=$(curl -s -G "http://127.0.0.1:8000/chat" --data-urlencode "message=Hello")

if [[ $CHAT_RESPONSE == *"data:"* ]]; then
  echo "Chat endpoint is working!"
else
  echo "Chat endpoint test failed!"
  kill $SERVER_PID
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
kill $SERVER_PID

if [[ $JS_EXIT_CODE -eq 0 ]]; then
  echo "History endpoint is working!"
  exit 0
else
  echo "History endpoint test failed!"
  exit 1
fi