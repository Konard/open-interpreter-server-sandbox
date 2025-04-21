import os
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from interpreter import interpreter

# —— Load OpenAI-compatible settings from the environment —— #
base_url = os.getenv("OPENAI_BASE_URL")
if base_url:
    interpreter.llm.api_base = base_url    # point at your custom API server  [oai_citation_attribution:0‡Open Interpreter](https://docs.openinterpreter.com/language-models/local-models/lm-studio) [oai_citation_attribution:1‡Open Interpreter](https://docs.openinterpreter.com/settings/all-settings)

api_key = os.getenv("OPENAI_API_KEY")
if api_key:
    interpreter.llm.api_key = api_key      # authenticate with your key  [oai_citation_attribution:2‡Open Interpreter](https://docs.openinterpreter.com/language-models/local-models/lm-studio) [oai_citation_attribution:3‡Open Interpreter](https://docs.openinterpreter.com/settings/all-settings)

default_model = os.getenv("DEFAULT_MODEL")
if default_model:
    interpreter.llm.model = default_model  # override the LLM model (e.g. "o3-mini")  [oai_citation_attribution:4‡GitHub](https://github.com/OpenInterpreter/open-interpreter)

app = FastAPI()

@app.get("/chat")
def chat_endpoint(message: str):
    """SSE stream of interpreter.chat responses."""
    def event_stream():
        for result in interpreter.chat(message, stream=True):
            yield f"data: {result}\n\n"
    return StreamingResponse(event_stream(), media_type="text/event-stream")

@app.get("/history")
def history_endpoint():
    """Returns full message history."""
    return interpreter.messages

# Alternatively, start identical server with:
# interpreter.server()