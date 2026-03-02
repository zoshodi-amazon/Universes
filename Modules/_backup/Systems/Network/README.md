# Network

System networking configuration.

## Structure

```
Network/
├── Types/
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
Types/NixNetwork/  → Monads/IOMNixNetwork/   [OK]
```