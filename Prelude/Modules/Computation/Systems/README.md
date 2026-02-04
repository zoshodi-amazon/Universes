# Systems

NixOS system configurations and bootable image generation.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Systems |
| Purpose | Build bootable NixOS images for any target |
| Targets | nixosConfigurations, packages (VM, ISO, SD) |

## Profiles

| Profile | Description |
|---------|-------------|
| `minimal` | Bare minimum, no SSH |
| `headless` | Server with hardened SSH |
| `workstation` | Desktop with WM, terminal |
| `sovereignty` | Self-hosting with impermanence |

## Hardware Targets

| Target | Architecture | Notes |
|--------|--------------|-------|
| `x86_64` | x86_64-linux | Standard PC/server |
| `rpi4` | aarch64-linux | Raspberry Pi 4 (stable) |
| `rpi5` | aarch64-linux | Raspberry Pi 5 (experimental) |

## Image Formats

| Format | Use Case |
|--------|----------|
| `vm` | Quick QEMU testing |
| `iso` | USB installer |
| `raw-efi` | Direct disk flash |
| `sd-card` | Raspberry Pi |
| `qcow` | Libvirt/KVM |

## Options

### Core (`nixosSystems.core.*`)

| Option | Type | Default |
|--------|------|---------|
| `username` | str | `"nixos"` |
| `hostname` | str | `"nixos"` |
| `locale` | str | `"en_US.UTF-8"` |
| `timezone` | str | `"UTC"` |
| `stateVersion` | str | `"24.11"` |
| `networking.firewall` | bool | `true` |
| `networking.ssh` | bool | `true` |
| `networking.networkManager` | bool | `true` |

### Hardware (`nixosSystems.hardware.*`)

| Option | Type | Default |
|--------|------|---------|
| `target` | enum | `"x86_64"` |
| `format` | enum | `"vm"` |

### Desktop (`nixosSystems.desktop.*`)

| Option | Type | Default |
|--------|------|---------|
| `enable` | bool | `false` |
| `wm` | enum | `"none"` |
| `terminal` | enum | `"alacritty"` |

### Impermanence (`nixosSystems.impermanence.*`)

| Option | Type | Default |
|--------|------|---------|
| `enable` | bool | `false` |
| `strategy` | enum | `"btrfs"` |
| `persistPath` | str | `"/persistent"` |
| `directories` | list | `["/var/log", ...]` |
| `files` | list | `["/etc/machine-id"]` |

## Usage

```bash
# Build and run VM (quick test)
nix run .#minimal-vm
nix run .#workstation-vm

# Build ISO
nix build .#minimal-iso

# Interactive flash script
nix run .#flash

# CLI flash
nix run .#flash -- --profile workstation --format raw-efi --device /dev/sda
```

## NixOS Configurations

Available at `flake.nixosConfigurations.*`:

- `minimal-x86_64`
- `headless-x86_64`
- `workstation-x86_64`
- `sovereignty-x86_64`
- `minimal-rpi4`
- `headless-rpi4`
