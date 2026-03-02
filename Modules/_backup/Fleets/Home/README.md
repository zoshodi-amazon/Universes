# Home

Home-manager configuration instantiation.

## Structure

```
Home/
├── Types/
│   ├── NixDarwin/default.nix    # Darwin home options
│   ├── NixCloudDev/default.nix  # Cloud-dev home options
│   ├── NixCloudNix/default.nix  # Cloud-nix home options
│   ├── NixPackages/default.nix  # Core packages list
│   └── default.nix
├── Monads/
│   ├── IOMNixHome/default.nix   # Enables defaults + packages
│   └── default.nix
├── default.nix                  # → flake.homeConfigurations
└── README.md
```

## Invariant Check

```
Types/NixDarwin/    → Monads/IOMNixHome/   [OK]
Types/NixCloudDev/  → (consumed by IOMNixHome)   [OK]
Types/NixCloudNix/  → (consumed by IOMNixHome)   [OK]
Types/NixPackages/  → (consumed by IOMNixHome)   [OK]
```