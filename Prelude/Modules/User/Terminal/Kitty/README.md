# Kitty

Terminal emulator configuration.

## Structure

```
Kitty/
├── Artifacts/NixKitty/default.nix   # font, theme, settings
├── Monads/IOMNixKitty/default.nix
├── default.nix                      # → flake.modules.homeManager.kitty
└── README.md
```

## Invariant Check

```
Artifacts/NixKitty/  → Monads/IOMNixKitty/   [OK]
```
