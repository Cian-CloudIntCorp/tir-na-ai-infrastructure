#!/bin/bash
# Tír-na-AI: Dynamic Headscale Installer
# Automatically fetches the latest stable release from GitHub.

echo "🔍 Checking GitHub for the latest Headscale release..."

# 1. Fetch the latest tag name from GitHub API
LATEST_TAG=$(curl -s https://api.github.com/repos/juanfont/headscale/releases/latest | grep -Po '"tag_name": "v\K[^"]*')

if [ -z "$LATEST_TAG" ]; then
    echo "❌ Error: Could not fetch latest version. Falling back to 0.23.0"
    LATEST_TAG="0.23.0"
fi

URL="https://github.com/juanfont/headscale/releases/download/v${LATEST_TAG}/headscale_${LATEST_TAG}_linux_amd64.deb"

echo "📥 Downloading Headscale v${LATEST_TAG}..."
wget -q --show-progress $URL -O headscale_latest.deb

# 2. Install the package
echo "⚙️ Installing package..."
sudo apt install ./headscale_latest.deb -y

# 3. Cleanup and service check
rm headscale_latest.deb
sudo systemctl enable --now headscale

echo "✅ Headscale v${LATEST_TAG} is now running."
echo "🔗 Access your mesh at: http://$(hostname -I | awk '{print $1}'):8080"
