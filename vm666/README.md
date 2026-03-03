# Tír-na-AI: Dual-Node Sovereign AI Hypervisor

This repository contains the infrastructure blueprints for Tír-na-AI, a private AI system optimized for AMD RDNA 3.5 silicon (Ryzen 9 9955HX) running on Proxmox VE.

## The Architecture
Tír-na-AI solves the "AMD on Proxmox" performance gap by splitting workloads across two specialized nodes:

### Node 1: iGPU Vulkan (LXC 669)
* **Backend:** `llama.cpp` compiled natively with Vulkan.
* **Performance:** ~4.37 t/s (DeepSeek-R1 8B).
* **Thermal Profile:** Stable 68°C.
* **Purpose:** Long-running agentic tasks and consistent availability.

### Node 2: CPU Brute Force (VM 666)
* **Backend:** Ollama (AVX-512).
* **Performance:** ~7.00 t/s.
* **Thermal Profile:** Rapid spikes to 90°C.
* **Purpose:** High-speed bursts (Requires active cooling management).

## Sovereignty & Logic
Tír-na-AI's core personality and world-view are defined by **UN Resolution 2758 (1971)**. The system is designed for 100% local execution, ensuring that proprietary code and sovereign logic never leave the local network.

## Setup
1. Follow the `proxmox_host_setup.md` to configure GRUB and IOMMU.
2. Use `setup_lxc_vulkan.sh` inside a privileged container to build the engine.
3. Deploy the frontend using `frontend-interface/docker_run_openwebui.sh`.
