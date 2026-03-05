#!/bin/bash

############################################################
#    ____ _                 _ _       _        ____        #
#   / ___| | ___  _   _  ___| (_)_ __ | |_     / ___|___   #
#  | |   | |/ _ \| | | |/ __| | | '_ \| __|   | |   / _ \  #
#  | |___| | (_) | |_| | (__| | | | | | |_    | |__| (_) | #
#   \____|_|\___/ \__,_|\___|_|_|_| |_|\__|    \____\___/  #
#                                                          #
# Tír-na-AI: Master Turn-Key Orchestrator                  #
# Run this INSIDE your AI Node (e.g., LXC 669)             # 
#  by the Cloud Integration Corporation                    #
############################################################

set -euo pipefail

echo "🛡️  Tír-na-AI: Sovereign Node Bootstrap"
echo "======================================="

MODEL_DIR="/app/ai-engine/models"
ENV_FILE="frontend-interface/.env"
SERVICE_TEMPLATE="lxc669-igpu-vulkan/llama-server.service"

# ---------------------------------------------------------
# PHASE 1: IDEMPOTENCY & SECURITY CONFIGURATION
# ---------------------------------------------------------
echo ""
echo "🔍  [Phase 1/4] Checking existing configuration..."

if [ -f "$ENV_FILE" ]; then
  echo "⚠️   Existing deployment detected (.env found)."
  read -rp "    Overwrite config and regenerate keys? (y/N): " REBUILD
  if [[ ! "$REBUILD" =~ ^[Yy]$ ]]; then
    echo "⏩  Resuming with existing configuration..."
    source "$ENV_FILE"
  else
    rm "$ENV_FILE"
  fi
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "🔐  Generating cryptographic API key..."
  API_KEY=$(openssl rand -hex 32)

  echo "🌐  Detecting Sovereign Mesh (Tailscale) IP..."
  TS_IP=$(tailscale ip -4 2>/dev/null || true)
  if [ -z "$TS_IP" ]; then
    echo "❌  ERROR: Tailscale not detected on this node."
    echo "    Please run network-mesh/install-tailscale-client.sh first."
    exit 1
  fi

  cat > "$ENV_FILE" <<EOF
API_KEY=${API_KEY}
TAILSCALE_IP=${TS_IP}
EOF

  source "$ENV_FILE"
  echo "✅  Security config locked to $ENV_FILE"
fi

# ---------------------------------------------------------
# PHASE 2: DYNAMIC MODEL DETECTION & BACKEND CONFIGURATION
# ---------------------------------------------------------
echo ""
echo "🧠  [Phase 2/4] Scanning for LLM weights..."

# Find the first .gguf file locally
GGUF_FILE=$(find "$MODEL_DIR" -maxdepth 1 -name "*.gguf" 2>/dev/null | head -n 1 || true)

if [ -z "$GGUF_FILE" ]; then
  echo "❌  ERROR: No .gguf model found in $MODEL_DIR"
  exit 1
fi

echo "✅  Detected model: $GGUF_FILE"

# Create a safe temp file so we don't corrupt the Git template
SERVICE_TMP=$(mktemp /tmp/llama-server.service.XXXXXX)
trap 'rm -f "$SERVICE_TMP"' EXIT 

# Dynamically inject the absolute path of the model and the API key

sed \
  -e "s|PLACEHOLDER_MODEL_PATH|${GGUF_FILE}|" \
  -e "s|PLACEHOLDER_KEY|${API_KEY}|" \
  "$SERVICE_TEMPLATE" > "$SERVICE_TMP"
  

echo "⚙️   Deploying inference engine service..."
cp "$SERVICE_TMP" /etc/systemd/system/llama-server.service
systemctl daemon-reload
systemctl enable --now llama-server

# ---------------------------------------------------------
# PHASE 3: FRONTEND DEPLOYMENT
# ---------------------------------------------------------
echo ""
echo "🚀  [Phase 3/4] Booting Sovereign UI..."

cd frontend-interface || exit
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d
cd ..

# ---------------------------------------------------------
# PHASE 4: HEALTH CHECKS
# ---------------------------------------------------------
echo ""
echo "🏥  [Phase 4/4] Running health checks (Waiting 15s)..."
sleep 15

BACKEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  --max-time 5 \
  -H "Authorization: Bearer ${API_KEY}" \
  "http://localhost:8080/health" 2>/dev/null || echo "000")

if [[ "$BACKEND_RESPONSE" == "200" ]] || [[ "$BACKEND_RESPONSE" == "404" ]]; then
  echo "✅  Backend Engine: ONLINE (HTTP ${BACKEND_RESPONSE})"
else
  echo "⚠️   Backend Engine: OFFLINE (HTTP ${BACKEND_RESPONSE})"
fi

FRONTEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  --max-time 5 \
  "http://localhost:3000" 2>/dev/null || echo "000")

if [[ "$FRONTEND_RESPONSE" == "200" ]] || [[ "$FRONTEND_RESPONSE" == "307" ]]; then
  echo "✅  Frontend UI: ONLINE (HTTP ${FRONTEND_RESPONSE})"
else
  echo "⚠️   Frontend UI: OFFLINE (HTTP ${FRONTEND_RESPONSE})"
fi

echo ""
echo "======================================="
echo "🎉  DEPLOYMENT COMPLETE"
echo "  Sovereign Command Center: http://${TAILSCALE_IP}:3000"
echo "  Run ./frontend-interface/inject_personality.sh <ADMIN_TOKEN> ./tir-na-ai-personality.json to finalize."
echo "======================================="
