# Machines

Machine fleet management and deployment.

**Pattern Version: v1.0.3** | **Structure: FROZEN**

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Machines |
| Purpose | Define and deploy NixOS machines |
| Targets | nixosConfigurations, Clan |

## Questions

| # | Question | Option Path | Type |
|---|----------|-------------|------|
| 1 | What is this machine called? | `identity.hostname` | `str` |
| 2 | What architecture? | `target.arch` | `x86_64 \| aarch64` |
| 3 | How do I deploy it? | `format.type` | `iso \| vm \| sd-image \| raw-efi` |
| 4 | What survives reboot? | `persistence.strategy` | `full \| impermanent \| ephemeral` |
| 5 | Where is persistent storage? | `persistence.device` | `str?` |

## Usage

```nix
machines.sovereignty = {
  identity.hostname = "sovereignty";
  target.arch = "x86_64";
  format.type = "iso";
  persistence.strategy = "impermanent";
  persistence.device = "/dev/disk/by-label/NIXOS_PERSIST";
};
```

## Bindings

| Option | Implementation |
|--------|----------------|
| `format.type = "iso"` | `system.build.isoImage` via Clan |
| `persistence.strategy = "impermanent"` | `nix-community/impermanence` |

## Commands

```bash
just list              # List all machines
just build sovereignty # Build machine image
just flash sovereignty /dev/sda  # Flash to USB
just vm sovereignty    # Run in VM
```
