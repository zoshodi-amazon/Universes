# Systems

NixOS system configurations via nixos-generators.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Systems |
| Purpose | Build bootable NixOS images (MicroVM, ISO, etc.) |
| Targets | packages, nixosConfigurations |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `perSystem.packages.microvm`, `flake.nixosConfigurations.microvm` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| MicroVM | enable, memory, vcpu, modules | Scripts (build, run) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `systems.microvm.enable` | bool | true |
| `systems.microvm.memory` | int | 1024 |
| `systems.microvm.vcpu` | int | 2 |

## Usage

```bash
# Build MicroVM image
nix build .#packages.x86_64-linux.microvm

# Run with QEMU
./result/bin/run-microvm-vm
```
