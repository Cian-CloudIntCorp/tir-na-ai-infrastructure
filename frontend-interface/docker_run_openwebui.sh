#!/bin/bash
# Tír-na-AI: Verified Production UI Deployment

docker run -d -p 3000:8080 \
  --name open-webui \
  --add-host=host.docker.internal:host-gateway \
  -e OPENAI_API_BASE_URL="http://host.docker.internal:8080/v1" \
  -e OPENAI_API_KEY="tir-na-ai-key" \
  -e WEBUI_NAME="Tír-na-AI" \
  -v open-webui:/app/data \
  --restart always \
  ghcr.io/open-webui/open-webui:main

echo "UI started. Wait 30 seconds for the container to become healthy before injecting personality."
