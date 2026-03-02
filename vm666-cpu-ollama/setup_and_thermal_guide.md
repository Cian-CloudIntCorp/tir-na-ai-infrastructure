# Node 666: CPU Brute Force (Ollama)

While Node 669 handles efficient, continuous uptime via the iGPU, Node 666 is a Virtual Machine dedicated to high-speed burst reasoning using the Ryzen 9 9955HX's AVX-512 CPU instructions.

## The ROCm Pivot
Initially, standard AMD ROCm was tested on this node. However, due to hypervisor passthrough limitations and the lack of official ROCm support for the RDNA 3.5 architecture (890M), the system defaulted to CPU inference. 

## Thermal Warning & Mitigation 🚨
Running 8B+ parameter models on bare CPU cores generates massive heat. During testing, unchecked CPU inference caused rapid thermal spikes exceeding 90°C. 

To prevent thermal shutdown and hardware degradation, you **must** limit the thread count in Ollama.

### How to throttle the CPU engine:
If you are running Ollama as a systemd service, edit the service file:
`sudo systemctl edit ollama`

Add the following environment variables to restrict CPU thread usage:
```ini
[Service]
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_THREADS=8"
