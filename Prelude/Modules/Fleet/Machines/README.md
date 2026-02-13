# Machines

Machine definitions and NixOS configuration instantiation.

## Structure

```
Machines/
├── Artifacts/
│   ├── NixMachines/default.nix  # Machine definitions (hostname, arch, format, disk, persistence, users)
│   ├── NixMicroVM/default.nix   # MicroVM config (mem, vcpu, hypervisor)
│   └── default.nix
├── Monads/
│   ├── IOMNixMachines/default.nix  # Sets machine defaults (sovereignty, test-vm)
│   └── default.nix
├── default.nix                  # → flake.nixosConfigurations + perSystem.packages
└── README.md
```

## Invariant Check

```
Artifacts/NixMachines/  → Monads/IOMNixMachines/   [OK]
Artifacts/NixMicroVM/   → (consumed by IOMNixMachines)   [OK]
```
