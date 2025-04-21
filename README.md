# Open Interpreter API Client

A minimal standalone repository demonstrating how to interact with the OpenInterpreter FastAPI server via HTTP APIs using both JavaScript and Python clients, leveraging the built-in \`interpreter.server()\` helper or custom endpoints.

## Repository Structure

\`\`\`
open-interpreter-api-client/
├── server/
│   ├── Dockerfile
│   └── server.py
├── client-js/
│   └── index.js
├── client-python/
│   └── client.py
├── .env.example
└── README.md
\`\`\`

## server/server.py

- \`/chat\` — SSE streaming of \`interpreter.chat()\`
- \`/history\` — full message history
- or simply \`interpreter.server()\`

## Clients

- **JS**: Streams events from \`/chat\`
- **Python**: Streams events line-by-line

## Usage

1. \`cd server\` and run:
   \`\`\`bash
   pip install fastapi uvicorn openinterpreter
   uvicorn server:app --reload --host 0.0.0.0 --port 8000
   \`\`\`
2. In separate terminals, run either client:
   \`\`\`bash
   # JavaScript
   cd client-js
   yarn add node-fetch dotenv
   node index.js

   # Python
   cd client-python
   pip install requests python-dotenv
   python client.py
   \`\`\`
