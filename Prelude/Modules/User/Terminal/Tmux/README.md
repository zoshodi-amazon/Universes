# Tmux

Terminal multiplexer with vim-style navigation.

## Structure

```
Tmux/
├── Artifacts/NixTmux/default.nix    # prefix, baseIndex, mouse, terminal, extraConfig
├── Monads/IOMNixTmux/default.nix    # Enables + passthrough
├── default.nix                      # → flake.modules.homeManager.tmux
└── README.md
```

## Invariant Check

```
Artifacts/NixTmux/  → Monads/IOMNixTmux/   [OK]
```
