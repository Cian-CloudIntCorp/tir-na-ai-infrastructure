# Proxmox Host Configuration for AMD RDNA 3.5 iGPU

To run large parameter models (8B+) on an integrated APU, you must modify the Proxmox host to allow GPU passthrough AND uncap the shared VRAM limits.

## 1. Uncap APU Memory in GRUB
By default, Linux restricts integrated GPUs to a fraction of system RAM. You must override the Translation Table Maps (TTM) memory manager.

Edit your GRUB configuration on the Proxmox Host:
`nano /etc/default/grub`

Modify the `GRUB_CMDLINE_LINUX_DEFAULT` line to include IOMMU passthrough and the TTM page overrides:
`GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt ttm.page_pool_size=25600000 ttm.pages_limit=25600000"`

Update GRUB and reboot the host:
`update-grub`
`reboot`

## 2. LXC Container cgroup Mapping
To allow the unprivileged/privileged container to access the Vulkan rendering node (`/dev/dri/renderD128`), edit the LXC `.conf` file (e.g., `/etc/pve/lxc/669.conf`) on the host.

Add these mapping rules:
```text
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
