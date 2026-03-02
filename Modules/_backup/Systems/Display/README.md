# Display

System display and window manager configuration.

## Structure

```
Display/
├── Types/
│   ├── NixDisplay/default.nix   # Display options (backend, greeter)
│   └── default.nix
├── Monads/
│   ├── IOMNixDisplay/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.nixos.display
└── README.md
```

## Invariant Check

```
Types/NixDisplay/  → Monads/IOMNixDisplay/   [OK]
```