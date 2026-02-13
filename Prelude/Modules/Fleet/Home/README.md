# Home

Home-manager configuration instantiation.

## Structure

```
Home/
├── Artifacts/
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
Artifacts/NixDarwin/    → Monads/IOMNixHome/   [OK]
Artifacts/NixCloudDev/  → (consumed by IOMNixHome)   [OK]
Artifacts/NixCloudNix/  → (consumed by IOMNixHome)   [OK]
Artifacts/NixPackages/  → (consumed by IOMNixHome)   [OK]
```