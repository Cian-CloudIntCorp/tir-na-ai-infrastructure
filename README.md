<div align="center">
  <h1>🛡️ Tír-na-AI: The "Everyman" Sovereign AI Node</h1>
  <p><b>Private, local, zero-cloud — Powered by Vulkan for universal iGPU & CPU compatibility on Proxmox VE.</b></p>
</div>

Most local AI deployments assume you own an expensive, dedicated NVIDIA GPU. **Tír-na-AI is different.** By utilizing the Vulkan API and advanced Proxmox container mapping, this stack bypasses standard hypervisor bottlenecks to unlock the raw power of **Integrated GPUs (iGPUs)**. Whether you are running an AMD RDNA chip or Intel Xe graphics, Tír-na-AI turns standard APU hardware into a secure, high-speed, enterprise-grade inference appliance. 

Coupled with a dynamic Tailscale/Headscale mesh network, the AI command center remains **100% mathematically invisible** to your local LAN and the open internet.

---

## 📖 About the Project

### 1. True Data Sovereignty
Tír-na-AI is designed for absolute privacy. Proprietary code, chat histories, and prompts never leave your secure mesh network. Furthermore, the system is injected at boot with a strict geopolitical worldview anchored in international law and UN Resolution 2758 (1971), ensuring neutral, non-corporate, sovereign outputs. 

### 2. Zero-Trust Architecture
We do not bind services to `0.0.0.0`. The entire stack (Backend Engine + Web UI) communicates exclusively over a WireGuard-backed Tailscale IP. If a device is not explicitly invited to your mesh network, the AI does not exist to them.



### 3. Dual-Mode Enterprise Orchestration
Our turn-key `bootstrap.sh` script is built for everyone:
* **Standard Mode (Homelab):** Automatically generates secure, 256-bit cryptographic API keys locally.
* **97%+++ Enterprise Mode (Power Users):** Natively integrates with HashiCorp Vault via AppRole authentication, ensuring your master API keys exist only in RAM and never touch the hard drive. Take it to 99% yourself by cycling the Vault `secret_id` keys every 30 days (`secret_id_ttl=720h`).

---

## 🏗️ The Split-Node Architecture

Tír-na-AI solves the "APU-on-Proxmox" compute gap by splitting workloads across specialized nodes, secured by a dedicated control plane.

| Node | Role | Technology | Performance |
| :--- | :--- | :--- | :--- |
| **LXC 100** | Sovereign Router (Control Plane) | Headscale | Lightweight |
| **LXC 101** | Sovereign Secrets (Control Plane) | HashiCorp Vault | Lightweight |
| **LXC 669** | Primary Compute Node | Vulkan API / llama.cpp | Maximum efficiency using shared VRAM |
| **VM 666** | CPU Brute Force Node | Ollama (AVX-512) | High-speed burst inference |

---

## ⏱️ Time & Hardware Requirements

### Minimum Hardware Requirements
| Component | Minimum | Recommended (Our Test Bench) |
| :--- | :--- | :--- |
| **Processor** | Any Vulkan-compatible APU/CPU | AMD Ryzen 9 9955HX (Strix Point) |
| **RAM** | 32GB DDR5 (shared with iGPU) | 64GB DDR5 |
| **Storage** | 50GB free | 100GB+ NVMe SSD |
| **Host OS** | Proxmox VE 8.x | Proxmox VE 8.x |

> **RAM Note:** Because integrated GPUs use system RAM as VRAM, running an 8B parameter model at Q4 quantization requires ~6–8GB of RAM dedicated exclusively to the GPU. 32GB total is the practical minimum for the hypervisor.

### Estimated Deployment Time
| Phase | Task | Time |
| :--- | :--- | :--- |
| **Phase 1** | Proxmox GRUB + cgroup config | ~15 min |
| **Phase 2** | Mesh network setup (Headscale + Tailscale) | ~10 min |
| **Phase 3** | Vulkan SDK install + llama.cpp compile | 25–40 min |
| **Phase 4** | Model download (8B Q4 ~4.5GB) | 5–20 min |
| **Phase 5** | Bootstrap + health checks + inline injection | ~5 min |
| **Total** | **First-time full deployment** | **60–90 min** |

> **Fast Redeployment:** Re-deploying after initial setup (e.g., swapping models, rotating Vault keys, or restarting the UI) takes under 2 minutes. Just re-run `./bootstrap.sh`.

---

## 📁 Repository Structure

```text
tir-na-ai-infrastructure/
├── bootstrap.sh                        # Dual-Mode Master Orchestrator (Standard/Vault)
├── README.md
├── network-mesh/
│   ├── install-headscale.sh            # Run on Router LXC (e.g., LXC 100)
│   └── install-tailscale-client.sh     # Run on Compute LXC (e.g., LXC 669)
├── lxc669-igpu-vulkan/
│   ├── proxmox_host_setup.md           # GRUB + cgroup passthrough instructions
│   ├── setup_lxc_vulkan.sh             # Vulkan SDK + llama.cpp build script
│   └── llama-server.service            # Systemd service template (Zero-Trust IP Bound)
├── frontend-interface/
│   ├── docker-compose.yml              # Open WebUI
│   └── tir-na-ai-logo.png
└── vm666/                              # CPU burst node configs (AVX-512)
```

---

## 🚀 Deployment Guide

> **Important:** Each phase runs on a different machine. Read the context note at the top of each phase carefully.

### Phase 1: Proxmox Host Preparation
🖥️ **Run on:** Proxmox bare-metal host (Not inside any LXC or VM)

By default, Linux restricts integrated GPUs to a fraction of system RAM. You must override the TTM memory manager to allow models to load fully into VRAM.
1. SSH into your Proxmox Host.
2. Read `lxc669-igpu-vulkan/proxmox_host_setup.md` and follow the instructions to append the `ttm` overrides to GRUB and pass `/dev/dri/renderD128` to your LXC container.
3. Reboot the Proxmox host.



### Phase 2: Sovereign Mesh Setup
🌐 **Step A runs on:** Router Node (LXC 100)  |  **Step B runs on:** Compute Node (LXC 669)

**Step A — Deploy the Router (LXC 100):**
```bash
git clone [https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git](https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git) 
cd tir-na-ai-infrastructure/network-mesh
chmod +x install-headscale.sh && ./install-headscale.sh
```
*(Note the output IP and port — you will need it for Step B).*

**Step B — Connect the Compute Node (LXC 669):**
```bash
git clone [https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git](https://github.com/Cian-CloudIntCorp/tir-na-ai-infrastructure.git) 
cd tir-na-ai-infrastructure/network-mesh
chmod +x install-tailscale-client.sh
./install-tailscale-client.sh http://<YOUR_HEADSCALE_IP>:8080
```

### Phase 3: Build the Vulkan Inference Engine
🧠 **Run on:** Compute Node (LXC 669)

This phase installs the LunarG Vulkan SDK and compiles `llama.cpp` from source. (Expect 25–40 minutes).
```bash
cd ~/tir-na-ai-infrastructure
chmod +x lxc669-igpu-vulkan/setup_lxc_vulkan.sh
./lxc669-igpu-vulkan/setup_lxc_vulkan.sh
```

**Download your Model:**
```bash
wget -P /app/ai-engine/models/ [https://huggingface.co/.../your-model.gguf](https://huggingface.co/.../your-model.gguf)
```

### Phase 4: Bootstrap the Appliance (Dual-Mode)
⚡ **Run on:** Compute Node (LXC 669) — *This is the only command you need for all future deployments.*

`bootstrap.sh` is the master orchestrator. It handles systemd deployment, UI booting, Zero-Trust network binding, and inline personality injection. 

**Option A: Standard Mode (Local Homelab)**
Generates a highly secure 256-bit cryptographic API key locally.
```bash
cd ~/tir-na-ai-infrastructure
./bootstrap.sh
```

**Option B: Enterprise Mode (HashiCorp Vault Integration)**
For advanced deployments. Skips local generation and pulls the master API key securely into RAM via an AppRole, ensuring zero secrets are stored on the disk.
```bash
cd ~/tir-na-ai-infrastructure

VAULT_ADDR="http://<YOUR_VAULT_IP>:8200" \
VAULT_ROLE_ID="<YOUR_ROLE_ID>" \
VAULT_SECRET_ID="<YOUR_SECRET_ID>" \
./bootstrap.sh
```

---

## ✅ Setup Complete
Your Tír-na-AI Sovereign Node is fully operational at: **`http://<YOUR_TAILSCALE_IP>:3000`**

Only devices enrolled in your Headscale mesh can reach this address. It does not appear on your local LAN.

## 🔧 Troubleshooting

| Symptom | SRE Debug Command |
| :--- | :--- |
| **Backend engine not starting** | `systemctl status llama-server` |
| **Backend engine logs** | `journalctl -u llama-server -n 50` |
| **Frontend UI not running** | `docker logs sovereign-ui` |
| **Tailscale IP not detected** | `tailscale ip -4` |
| **Check Vulkan GPU detection** | `vulkaninfo --summary` |
| **Check iGPU is passed through** | `ls /dev/dri/` |

---
*Built by Cian Egan — Cloud Integration Corporation*
