# SSH

SSH client configuration with host management.

## Structure

```
SSH/
├── Artifacts/NixSSH/default.nix     # SSH options (compression, keepalive, hosts)
├── Monads/IOMNixSSH/default.nix
├── default.nix                      # → flake.modules.homeManager.ssh
└── README.md
```

## Invariant Check

```
Artifacts/NixSSH/  → Monads/IOMNixSSH/   [OK]
```
