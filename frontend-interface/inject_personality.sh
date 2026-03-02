#!/bin/bash
# Tír-na-AI: Personality Injection Script

if [ -z "$1" ]; then
  echo "🚨 Error: Missing Admin Token."
  echo "Usage: ./inject_personality.sh <YOUR_ADMIN_JWT_TOKEN>"
  echo "To get your token: Log into Open WebUI -> Profile (bottom left) -> Settings -> Account -> API"
  exit 1
fi

ADMIN_TOKEN=$1

echo "Injecting Tír-na-AI personality from tir-na-ai-personality.json..."

curl -X POST http://localhost:3000/api/v1/models/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d @./tir-na-ai-personality.json

echo ""
echo "✅ Personality injected successfully."
echo "Note: To attach the logo, go to the UI -> Workspace -> Models -> Edit 'Tír-na-AI' -> Upload 'tir-na-ai-logo.png' from this repo."
