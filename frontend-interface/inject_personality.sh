#!/bin/bash
# Tír-na-AI: Multi-Model Personality Injection Script

if [ -z "$2" ]; then
  echo "🚨 Error: Missing arguments."
  echo "Usage: ./inject_personality.sh <ADMIN_TOKEN> <JSON_FILE_PATH> [OPTIONAL_URL]"
  echo "Example: ./inject_personality.sh sk-12345 ./tir-na-ai-personality.json"
  exit 1
fi

ADMIN_TOKEN=$1
JSON_FILE=$2

# Smart URL Detection: Auto-detect the Tailscale IP from our turn-key setup
if [ -n "$3" ]; then
  WEBUI_URL=$3
else
  if [ -f .env ]; then
    # Read the IP from the hidden file created by deploy-frontend.sh
    source .env
    WEBUI_URL="http://${TAILSCALE_IP}:3000"
  else
    # Fallback if .env is missing but Tailscale is running
    TS_IP=$(tailscale ip -4 2>/dev/null)
    if [ -n "$TS_IP" ]; then
      WEBUI_URL="http://${TS_IP}:3000"
    else
      WEBUI_URL="http://localhost:3000"
    fi
  fi
fi

echo "Injecting personality from $JSON_FILE into $WEBUI_URL..."

curl -X POST "$WEBUI_URL/api/v1/models/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d @"$JSON_FILE"

echo ""
echo "✅ Injection complete for $(grep -po '"name": *\K"[^"]*"' "$JSON_FILE" | head -1)"
