🛡️ Tír-na-AI: Dual-Node Sovereign AI Infrastructure
This repository contains the turn-key infrastructure blueprints for Tír-na-AI, a private, sovereign AI system optimized for AMD RDNA 3.5 silicon (Ryzen 9 9955HX) running on Proxmox VE.

By utilizing dynamic Tailscale/Headscale mesh networking and native Vulkan API rendering, this stack bypasses standard hypervisor virtualization bottlenecks, delivering maximum tokens-per-second while keeping the UI completely invisible to the local LAN.

🏗️ The Architecture
Tír-na-AI solves the "AMD on Proxmox" compute gap by splitting workloads across specialized nodes, secured by a dedicated control plane:

The Control Plane: Mesh Router (e.g., LXC 100)

Backend: Headscale (Open-source Tailscale control server).

Purpose: Acts as the Sovereign Router. Ensures the AI command center is mathematically invisible to the local Wi-Fi and open internet.

Node 1: iGPU Vulkan (LXC 669)

Backend: llama.cpp compiled natively with the LunarG Vulkan SDK.

Performance: ~4.37 t/s (DeepSeek-R1-Distill-Llama-8B-Q4_K_M.gguf).

Thermal Profile: Stable 68°C.

Purpose: Long-running agentic tasks and consistent, 24/7 API availability.

Node 2: CPU Brute Force (VM 666)

Backend: Ollama (AVX-512).

Performance: ~7.00 t/s.

Thermal Profile: Rapid spikes to 90°C.

Purpose: High-speed bursts (Requires active cooling management).

⚖️ Sovereignty & Logic
Tír-na-AI's core personality and worldview are strictly defined by UN Resolution 2758 (1971) and International Law directives. The system is designed for 100% local execution, ensuring that proprietary code, chat histories, and sovereign logic never leave the secure mesh network. Automated deployment scripts forcefully inject these directives into the UI upon initialization.

🚀 Turn-Key Deployment Guide
Phase 1: Proxmox Host Hypervisor Preparation
By default, the Linux kernel restricts integrated GPUs to a fraction of system RAM. You must override the Translation Table Maps (TTM) to allow massive 8B+ parameter models to load into VRAM.

SSH into your Proxmox Host.

Read the instructions in lxc669-igpu-vulkan/proxmox_host_setup.md.

Modify your host's GRUB config to uncap ttm.page_pool_size.

Update your LXC's .conf file with the provided cgroup2 mappings to allow /dev/dri/renderD128 passthrough.

Reboot the Proxmox Host.

Phase 2: Sovereign Mesh Setup (Control Plane)
The UI dynamically binds to a secure mesh IP. Deploy the router on a lightweight container, and connect your AI Compute node to it.

Deploy the Router: On a lightweight container (e.g., LXC 100), navigate to network-mesh/ and run ./install-headscale.sh. Note the IP and port (e.g., http://192.168.1.50:8080).

Connect the Compute Node: SSH into your AI Node (e.g., LXC 669), navigate to network-mesh/, and run ./install-tailscale-client.sh http://<YOUR_HEADSCALE_IP>:8080.

Phase 3: Bare-Metal Vulkan Engine (Node 1)
SSH into your AI Compute Node (LXC 669) as root.

Navigate to lxc669-igpu-vulkan/ and run ./setup_lxc_vulkan.sh.

Manual Step: Download your .gguf model into /app/ai-engine/models/ and rename it to Tir-na-AI.gguf.

Copy llama-server.service to /etc/systemd/system/.

Run: systemctl daemon-reload && systemctl enable --now llama-server

Phase 4: Frontend UI & Personality Injection
With the Vulkan engine running on port 8080, deploy the locked-down Open WebUI.

Navigate to frontend-interface/.

Run ./deploy-frontend.sh. (This auto-detects your Tailscale IP, creates a hidden .env file, and boots the Docker UI).

Open your browser and navigate to http://<YOUR_TAILSCALE_IP>:3000. Click Sign Up to claim the Master Admin account.

Go to Settings > Account in the UI and generate an Admin API Token (e.g., sk-12345...).

Inject Sovereignty: Back in the terminal, run the personality injector to push the UN Directives and branding into the database:
./inject_personality.sh <YOUR_ADMIN_TOKEN> ./tir-na-ai-personality.json

✅ Setup Complete. Your Tír-na-AI Sovereign Node is now fully operational.
