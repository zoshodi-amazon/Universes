# SSH

SSH client configuration with host management.

## Structure

```
SSH/
├── Types/NixSSH/default.nix     # SSH options (compression, keepalive, hosts)
├── Monads/IOMNixSSH/default.nix
├── default.nix                      # → flake.modules.homeManager.ssh
└── README.md
```

## Invariant Check

```
Types/NixSSH/  → Monads/IOMNixSSH/   [OK]
```
