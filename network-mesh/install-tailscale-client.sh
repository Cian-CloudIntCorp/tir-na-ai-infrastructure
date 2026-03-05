#!/bin/bash
# Tír-na-AI: Automated Tailscale Mesh Client Setup

echo "🛡️ Tír-na-AI Sovereign Mesh Client Installer"
echo "============================================="

if [ -z "$1" ]; then
  echo "🚨 Error: Missing Headscale Server URL."
  echo "Usage: ./install-tailscale-client.sh <HEADSCALE_URL>"
  echo "Example: ./install-tailscale-client.sh http://192.168.86.200:8080"
  exit 1
fi

HEADSCALE_URL=$1

# 1. Install Tailscale via the official deployment script
echo "📥 Downloading and installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# 2. Enable IP Forwarding (Crucial for container networking)
echo "⚙️ Configuring system network routing..."
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf > /dev/null
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# 3. Bind to the Sovereign Headscale Server
echo "🔗 Connecting node to Sovereign Mesh at $HEADSCALE_URL..."
sudo tailscale up --login-server="$HEADSCALE_URL" --accept-routes

echo "============================================="
echo "✅ Node successfully joined the mesh!"
echo "Your new Sovereign IP is: $(tailscale ip -4)"
