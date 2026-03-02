# Servers

Server infrastructure: containers, data stores, apps.

## Structure

```
Servers/
├── Types/
│   ├── NixContainers/default.nix    # Container orchestration
│   ├── NixObjectStore/default.nix   # S3-compatible storage
│   ├── NixPersistence/default.nix   # Storage backend selection
│   ├── Nix{Gateway,DNS,Identity,Metrics,InfraSecrets}/  # Infra (placeholder)
│   ├── Nix{Relational,Documents,Registry,Backup}/       # Data (placeholder)
│   ├── Nix{LLM,Chat,GitServer,Media}/                   # Apps (placeholder)
│   └── default.nix
├── Monads/
│   ├── IOMNixServers/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.nixos.servers
└── README.md
```

## Invariant Check

```
Types/NixContainers/   → Monads/IOMNixServers/   [OK]
Types/NixObjectStore/  → (consumed by IOMNixServers)   [OK]
Types/NixPersistence/  → (consumed by IOMNixServers)   [OK]
```