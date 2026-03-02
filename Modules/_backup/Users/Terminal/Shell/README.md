# Shell

Multi-shell configuration: Zsh, Fish, Nushell, Direnv.

## Structure

```
Shell/
├── Types/
│   ├── NixZsh/default.nix        NixFish/default.nix
│   ├── NixNushell/default.nix    NixDirenv/default.nix
│   ├── NixShellEnv/default.nix
│   └── default.nix
├── Monads/
│   ├── IOMNixShell/default.nix  # Enables all + aliases + paths
│   └── default.nix
├── default.nix                  # → flake.modules.homeManager.{shell,zsh,fish,nushell,direnv}
└── README.md
```

## Invariant Check

```
Types/NixZsh/      → Monads/IOMNixShell/   [OK]
Types/NixFish/     → (consumed by IOMNixShell)   [OK]
Types/NixNushell/  → (consumed by IOMNixShell)   [OK]
Types/NixDirenv/   → (consumed by IOMNixShell)   [OK]
Types/NixShellEnv/ → (consumed by IOMNixShell)   [OK]
```
