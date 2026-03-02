# Node 666: CPU "Hard Fence" (Ollama)

Node 666 is intentionally designed as a pure-CPU inference node. Because this Proxmox host is shared with other critical workloads (like RKE2 testing), we do not allow the AI to have unconstrained access to the CPU.

## The Proxmox "Hard Fence" Strategy
Instead of relying on software-level thread limiting inside Ollama (which can fail and cause 90°C+ thermal spikes), resource isolation is enforced at the hypervisor level.

### Proxmox UI Configuration:
1. **Cores:** Restricted to exactly 1/4th of the available host cores (e.g., 4 vCPUs out of 16).
2. **CPU Type:** Set to `host` to ensure AVX-512 instructions from the Ryzen 9 9955HX pass through to the VM for maximum inference speed on those 4 cores.
3. **Memory:** Hard-capped to prevent OOM (Out of Memory) crashes from bleeding into the host.

## The Engine
* **Deployment:** Docker
* **Image:** `ollama/ollama` (Standard CPU image. Do NOT use the `:rocm` tag here, as the missing iGPU passthrough causes unnecessary driver overhead).
* **Port:** 11434
