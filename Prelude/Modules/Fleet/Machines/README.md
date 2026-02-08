# Machines

Machine fleet management and deployment.

**Pattern Version: v1.0.5** | **Structure: FROZEN**

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Fleet / Machines |
| Purpose | Define and deploy NixOS machines |
| Targets | nixosConfigurations |

## Questions

| # | Question | Option Path | Type |
|---|----------|-------------|------|
| 1 | What is this machine called? | `identity.hostname` | `str` |
| 2 | What architecture? | `target.arch` | `x86_64 \| aarch64` |
| 3 | How do I deploy it? | `format.type` | `iso \| vm \| sd-image \| raw-efi \| oci \| microvm` |
| 4 | What disk layout? | `disk.layout` | `standard \| custom \| none` |
| 5 | What disk device? | `disk.device` | `str` |
| 6 | What survives reboot? | `persistence.strategy` | `full \| impermanent \| ephemeral` |
| 7 | Where is persistent storage? | `persistence.device` | `str?` |

## Deployment Paths

| Path | When | Command |
|------|------|---------|
| ISO (portable boot) | `format.type = "iso"` | `just flash sovereignty /dev/diskN` |
| nixos-anywhere (remote install) | `disk.layout != "none"` | `just remote-install cloud-dev sovereignty` |
| VM (local testing) | any | `just vm sovereignty` |
| OCI (container) | any | `just remote-build-oci cloud-dev sovereignty` |
| MicroVM (fast cloud test) | `format.type = "microvm"` | `just remote-microvm cloud-dev test-vm` |

Both ISO and disko can coexist: ISO for portable bootable media, disko for target machine partitioning via nixos-anywhere.

## Usage

```nix
machines.sovereignty = {
  identity.hostname = "sovereignty";
  target.arch = "x86_64";
  format.type = "iso";
  disk = {
    layout = "standard";
    device = "/dev/sda";
    persistLabel = "NIXOS_PERSIST";
  };
  persistence.strategy = "impermanent";
  persistence.device = "/dev/disk/by-label/NIXOS_PERSIST";
  users = [
    { name = "zoshodi"; home = "darwin"; }
  ];
};
```

## Commands

```bash
just list                                    # List all machines
just schema                                  # Show machine options schema
just build sovereignty                       # Build ISO
just flash sovereignty /dev/disk4            # Flash to USB
just vm sovereignty                          # Run in VM
just remote-build cloud-dev sovereignty      # Build ISO on remote
just remote-install cloud-dev sovereignty    # Install via nixos-anywhere + disko
just remote-build-oci cloud-dev sovereignty  # Build OCI on remote
```
