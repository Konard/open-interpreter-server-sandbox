# Optional: custom image to bundle your server
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libevdev-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server.py .

# Install only the required Python dependencies
RUN pip install --no-cache-dir fastapi uvicorn open-interpreter

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
