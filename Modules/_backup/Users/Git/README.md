# Git

Git identity, workflow, and global ignore configuration.

## Structure

```
Git/
├── Types/
│   ├── NixGit/default.nix       # Git options (identity, signing, aliases, ignores)
│   └── default.nix
├── Monads/
│   ├── IOMNixGit/default.nix    # Enables + default ignores
│   └── default.nix
├── default.nix                  # → flake.modules.homeManager.git
└── README.md
```

## Invariant Check

```
Types/NixGit/  → Monads/IOMNixGit/   [OK]
```
