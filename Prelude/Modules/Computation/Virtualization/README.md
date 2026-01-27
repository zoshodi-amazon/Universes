# Virtualization

Virtual machine management (Lima on macOS, MicroVM on NixOS).

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Virtualization |
| Purpose | Run Linux VMs locally |
| Targets | homeManager (Lima), nixos (MicroVM) |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `flake.modules.{homeManager.lima,nixos.microvm}` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Lima | enable | — |
| MicroVM | enable, memory, vcpu | Scripts |

## Options

| Option | Type | Default |
|--------|------|---------|
| `virtualization.lima.enable` | bool | true |
| `virtualization.microvm.enable` | bool | false |

## Usage

```bash
# Start default Lima VM
limactl start

# Run command in Lima
lima nix build .#packages.x86_64-linux.microvm

# Run the built VM
lima ./result/bin/run-nixos-vm
```
