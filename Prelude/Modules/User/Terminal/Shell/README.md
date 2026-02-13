# Shell

Multi-shell configuration: Zsh, Fish, Nushell, Direnv.

## Structure

```
Shell/
├── Artifacts/
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
Artifacts/NixZsh/      → Monads/IOMNixShell/   [OK]
Artifacts/NixFish/     → (consumed by IOMNixShell)   [OK]
Artifacts/NixNushell/  → (consumed by IOMNixShell)   [OK]
Artifacts/NixDirenv/   → (consumed by IOMNixShell)   [OK]
Artifacts/NixShellEnv/ → (consumed by IOMNixShell)   [OK]
```
