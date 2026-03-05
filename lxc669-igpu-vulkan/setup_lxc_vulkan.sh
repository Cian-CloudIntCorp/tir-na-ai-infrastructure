#!/bin/bash
# Tír-na-AI: LXC Vulkan Engine Installer
# Run this script INSIDE your privileged LXC container as root.

echo "Installing Vulkan dependencies (LunarG)..."
wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add -
wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list https://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
apt-get update && apt-get install -y vulkan-sdk libvulkan-dev vulkan-tools git build-essential cmake

echo "Cloning and building llama.cpp (Vulkan Native)..."
mkdir -p /app/ai-engine/models
git clone https://github.com/ggerganov/llama.cpp.git /app/ai-engine/llama.cpp
cd /app/ai-engine/llama.cpp
mkdir build && cd build
cmake .. -DGGML_VULKAN=ON
cmake --build . --config Release -j $(nproc)

echo "=================================================="
echo "Build complete!"
echo "Next steps:"
echo "1. Download your chosen .gguf model and place it in /app/ai-engine/models/"
echo "2. CRITICAL: Rename the model file to 'Tir-na-AI.gguf' so the service can find it."
echo "3. Copy the llama-server.service file to /etc/systemd/system/"
echo "4. systemctl daemon-reload && systemctl enable --now llama-server"
echo "=================================================="
