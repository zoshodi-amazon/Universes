# Tmux

Terminal multiplexer with vim-style navigation.

## Structure

```
Tmux/
├── Types/NixTmux/default.nix    # prefix, baseIndex, mouse, terminal, extraConfig
├── Monads/IOMNixTmux/default.nix    # Enables + passthrough
├── default.nix                      # → flake.modules.homeManager.tmux
└── README.md
```

## Invariant Check

```
Types/NixTmux/  → Monads/IOMNixTmux/   [OK]
```
