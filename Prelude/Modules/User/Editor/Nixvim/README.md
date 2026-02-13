# Nixvim

Neovim configuration via nixvim with full plugin ecosystem.

## Structure

```
Nixvim/
├── Artifacts/
│   ├── NixNvimCore/default.nix      # Core options (colorscheme, leader, tabs)
│   ├── NixNvimRender/default.nix    # Preview options (port, converters)
│   ├── NixNvim{Keymaps,Nix,Navigation,Completion,Languages,Inline,Chrome,Data,Git}/
│   └── default.nix
├── Monads/
│   ├── IOMNixNvim/default.nix       # All plugin configs + keymaps
│   └── default.nix
├── Drv/                             # Derivations (kept as-is)
├── default.nix                      # → flake.modules.homeManager.nixvim
└── README.md
```

## Invariant Check

```
Artifacts/NixNvimCore/    → Monads/IOMNixNvim/   [OK]
Artifacts/NixNvimRender/  → (consumed by IOMNixNvim)   [OK]
```
