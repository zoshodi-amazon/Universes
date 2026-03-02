# Kitty

Terminal emulator configuration.

## Structure

```
Kitty/
├── Types/NixKitty/default.nix   # font, theme, settings
├── Monads/IOMNixKitty/default.nix
├── default.nix                      # → flake.modules.homeManager.kitty
└── README.md
```

## Invariant Check

```
Types/NixKitty/  → Monads/IOMNixKitty/   [OK]
```
