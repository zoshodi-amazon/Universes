# Nix

Nix daemon optimization and configuration.

## Structure

```
Nix/
├── Artifacts/
│   ├── NixSettings/default.nix  # Nix daemon options (gc, optimise, jobs, cores)
│   └── default.nix
├── Monads/
│   ├── IOMNixSettings/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.{homeManager,nixos,darwin}.nix-settings
└── README.md
```

## Invariant Check

```
Artifacts/NixSettings/  → Monads/IOMNixSettings/   [OK]
```