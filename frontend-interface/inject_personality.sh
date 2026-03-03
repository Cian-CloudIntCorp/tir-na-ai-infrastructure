#!/bin/bash
# Tír-na-AI: Multi-Model Personality Injection Script

if [ -z "$2" ]; then
  echo "🚨 Error: Missing arguments."
  echo "Usage: ./inject_personality.sh <ADMIN_TOKEN> <JSON_FILE_PATH> [OPTIONAL_URL]"
  echo "Example: ./inject_personality.sh ghp_123 ./tir-na-ai-r1-8b.json http://192.168.86.204:3000"
  exit 1
fi

ADMIN_TOKEN=$1
JSON_FILE=$2
WEBUI_URL=${3:-"http://localhost:3000"}

echo "Injecting personality from $JSON_FILE into $WEBUI_URL..."

curl -X POST "$WEBUI_URL/api/v1/models/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d @"$JSON_FILE"

echo ""
echo "✅ Injection complete for $(grep -po '"name": *\K"[^"]*"' "$JSON_FILE" | head -1)"
