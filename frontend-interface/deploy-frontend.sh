#!/bin/bash

echo "🛡️ Tír-na-AI Sovereign Node Installer"
echo "======================================="

# 1. Check if Tailscale/Headscale is installed and grab the IP
echo "🔍 Searching for secure mesh network..."
TS_IP=$(tailscale ip -4 2>/dev/null)

if [ -z "$TS_IP" ]; then
  echo "❌ ERROR: Tailscale/Headscale IP not found."
  echo "Please install and connect your mesh network first to ensure a sovereign connection."
  exit 1
fi

echo "✅ Mesh network detected. Node IP: $TS_IP"

# 2. Write the IP to the hidden .env file for Docker Compose
echo "TAILSCALE_IP=$TS_IP" > .env
echo "🔒 Locking UI port strictly to your mesh network..."

# 3. Boot the infrastructure
echo "🚀 Booting Tír-na-AI Sovereign UI..."
docker compose up -d

echo "======================================="
echo "✅ SUCCESS! Your Sovereign Node is live on the mesh."
echo "UI started at http://$TS_IP:3000"
echo "⚠️  Wait 30 seconds for the container to become fully healthy,"
echo "then run: ./inject_personality.sh to load the UN directives and logo."
