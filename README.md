div align="center">
🛡️ Tír-na-AI
Dual-Node Sovereign AI Infrastructure
Private, local, zero-cloud — built for AMD RDNA 3.5 on Proxmox VE
</div>

By utilizing dynamic Tailscale/Headscale mesh networking and native Vulkan API rendering, this stack bypasses standard hypervisor virtualization bottlenecks — delivering maximum tokens-per-second while keeping the UI completely invisible to the local LAN.

⏱️ Time & Hardware Requirements
Estimated Deployment Time
PhaseTaskTimePhase 1Proxmox GRUB + cgroup config~15 minPhase 2Mesh network setup (Headscale + Tailscale)~10 minPhase 3Vulkan SDK install + llama.cpp compile~25–40 minPhase 3Model download (8B Q4 ~4.5GB)~5–20 min (network dependent)Phase 4Bootstrap + health checks + injection~5 minTotalFirst-time full deployment~60–90 min

Re-deploying after initial setup (e.g. swapping models or restarting the UI) takes under 2 minutes — just re-run ./bootstrap.sh.

Minimum Hardware Requirements
ComponentMinimumRecommendedCPUAMD Ryzen APU with RDNA iGPURyzen 9 9955HX (Strix Point)RAM32GB DDR5 (shared with iGPU VRAM)64GB DDR5Storage50GB free100GB+ NVMe SSDHost OSProxmox VE 8.xProxmox VE 8.xNetworkLocal LANLAN + internet (for initial setup only)

RDNA 3.5 note: This project is specifically optimised for the AMD 890M integrated GPU (Strix Point APU). It may work on other RDNA iGPUs but has only been validated on the Ryzen 9 9955HX.


RAM note: The iGPU shares system RAM as VRAM. Running a 8B Q4 model requires ~6–8GB dedicated to the GPU. 32GB total is the practical minimum — 64GB is strongly recommended for headroom.


🏗️ Architecture
Tír-na-AI solves the AMD-on-Proxmox compute gap by splitting workloads across specialised nodes, secured by a dedicated control plane.
NodeRoleBackendPerformanceThermalLXC 100Mesh Router (Control Plane)Headscale——LXC 669iGPU Vulkan Computellama.cpp + LunarG Vulkan SDK~4.37 t/sStable 68°CVM 666CPU Brute ForceOllama (AVX-512)~7.00 t/sSpikes to 90°C

LXC 100 acts as the Sovereign Router. Headscale ensures the AI command centre is invisible to the local LAN and open internet.
LXC 669 runs the primary inference engine natively via Vulkan — bypassing hypervisor DMA limits to use the full DDR5 memory pool as VRAM.
VM 666 provides high-speed CPU burst inference. Requires active cooling management.


⚖️ Sovereignty & Logic
Tír-na-AI's personality and worldview are governed by UN Resolution 2758 (1971) and international law directives. The system is designed for 100% local execution — proprietary code, chat histories, and sovereign logic never leave the secure mesh network.
Sovereign directives are automatically injected into the UI during bootstrap.

📁 Repository Structure
tir-na-ai-infrastructure/
├── bootstrap.sh                        # Master orchestrator — run inside LXC 669
├── README.md
├── network-mesh/
│   ├── install-headscale.sh            # Run on Router LXC (e.g. LXC 100)
│   └── install-tailscale-client.sh     # Run on Compute LXC (LXC 669)
├── lxc669-igpu-vulkan/
│   ├── proxmox_host_setup.md           # GRUB + cgroup passthrough instructions
│   ├── setup_lxc_vulkan.sh             # Vulkan SDK + llama.cpp build script
│   └── llama-server.service            # Systemd service template (do not edit)
├── frontend-interface/
│   ├── docker-compose.yml              # Open WebUI — bound to Tailscale IP
│   └── tir-na-ai-logo.png
└── vm666/                              # CPU burst node configs

🚀 Deployment Guide

Before you begin: Each phase runs on a different machine. Read the context note at the top of each phase carefully.


Phase 1: Proxmox Host Preparation

🖥️ Run on: Proxmox bare-metal host (not inside any LXC or VM)

By default, Linux restricts integrated GPUs to a fraction of system RAM. You must override the TTM memory manager to allow 8B+ parameter models to load fully into VRAM.

SSH into your Proxmox Host.
Read lxc669-igpu-vulkan/proxmox_host_setup.md and follow the instructions to:

Add ttm.page_pool_size and ttm.pages_limit overrides to GRUB.
Add cgroup2 device mappings to your LXC .conf file for /dev/dri/renderD128 passthrough.


Reboot the Proxmox host.


Phase 2: Sovereign Mesh Setup

🌐 Step A runs on: LXC 100 (Router) — Step B runs on: LXC 669 (Compute)

The UI binds exclusively to a Tailscale mesh IP. A split-node architecture keeps the mesh router on a separate lightweight container, avoiding port conflicts with the AI engine.
Step A — Deploy the Router (LXC 100):
Create a lightweight LXC container (Debian/Ubuntu, 512MB RAM is sufficient).
bash# Inside LXC 100
git clone https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git
cd tir-na-ai-infrastructure/network-mesh
chmod +x install-headscale.sh && ./install-headscale.sh
Note the output IP and port — you will need it in Step B (e.g. http://192.168.1.50:8080).
Step B — Connect the Compute Node (LXC 669):
bash# Inside LXC 669
git clone https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git
cd tir-na-ai-infrastructure/network-mesh
chmod +x install-tailscale-client.sh
./install-tailscale-client.sh http://<YOUR_HEADSCALE_IP>:8080
Note your new 100.x.x.x Tailscale IP — this is your Sovereign IP.

Phase 3: Build the Vulkan Inference Engine

🧠 Run on: LXC 669 (Compute Node)

This phase installs the LunarG Vulkan SDK and compiles llama.cpp from source. This only needs to run once. Expect 25–40 minutes.
bash# Inside LXC 669, from the repo root
cd tir-na-ai-infrastructure
chmod +x lxc669-igpu-vulkan/setup_lxc_vulkan.sh
./lxc669-igpu-vulkan/setup_lxc_vulkan.sh
Manual step — download your model:
bash# Any .gguf filename works — bootstrap.sh detects it automatically
wget -P /app/ai-engine/models/ https://huggingface.co/.../your-model.gguf

Tested with DeepSeek-R1-Distill-Llama-8B-Q4_K_M.gguf. Other 8B Q4 models should work.


Phase 4: Bootstrap the Appliance

⚡ Run on: LXC 669 (Compute Node) — this is the only command you need for all future deployments

This single script handles everything: key generation, service deployment, Docker UI, health checks, and sovereign personality injection.
bash# Inside LXC 669, from the repo root
chmod +x bootstrap.sh
./bootstrap.sh
The script will automatically:

Generate a 256-bit cryptographic API key and detect your Tailscale IP.
Scan /app/ai-engine/models/ for your .gguf file and deploy the systemd service.
Boot the Open WebUI Docker container, strictly bound to your Tailscale IP.
Run health checks against both the backend engine and the frontend UI.
Pause and prompt you to create your admin account, then inject the sovereign personality directives.


Note: The .env file generated by bootstrap contains your API key. It is git-ignored and never leaves your machine.

If bootstrap is interrupted or you need to re-run:
bash./bootstrap.sh
# Select N when asked to overwrite — completed phases are skipped automatically

✅ Setup Complete
Your Tír-na-AI Sovereign Node is fully operational at:
http://<YOUR_TAILSCALE_IP>:3000

Only devices enrolled in your Headscale mesh can reach this address. It does not appear on your local LAN.


🔧 Troubleshooting
SymptomCommandBackend engine not startingsystemctl status llama-serverBackend engine logsjournalctl -u llama-server -n 50Frontend container not runningdocker logs sovereign-uiTailscale IP not detectedtailscale ip -4Re-run personality injection only./bootstrap.sh → enter token at Phase 5 promptCheck Vulkan GPU detectionvulkaninfo --summaryCheck iGPU is passed throughls /dev/dri/

Built by Cian Egan — Cloud Integration Corporation
