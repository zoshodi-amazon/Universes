# Network

System networking configuration.

## Structure

```
Network/
├── Artifacts/
│   ├── NixNetwork/default.nix   # Network options (dhcp, firewall, ssh, wireless)
│   └── default.nix
├── Monads/
│   ├── IOMNixNetwork/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.nixos.network-config
└── README.md
```

## Invariant Check

```
Artifacts/NixNetwork/  → Monads/IOMNixNetwork/   [OK]
```