# Boot

System boot and disk partitioning configuration.

## Structure

```
Boot/
├── Artifacts/
│   ├── NixBoot/default.nix      # Boot config (loader, efi, kernel, initrd)
│   ├── NixDisk/default.nix      # Disk partitioning (devices, partitions)
│   └── default.nix
├── Monads/
│   ├── IOMNixBoot/default.nix   # Enables itself + disk auto-enable
│   └── default.nix
├── default.nix                  # → flake.modules.nixos.{boot-config,disk-config}
└── README.md
```

## Artifact/Monad 1-1 Mapping

| Artifact | Monad | Target |
|----------|-------|--------|
| `NixBoot` + `NixDisk` | `IOMNixBoot` | `flake.modules.nixos.boot-config` + `disk-config` |

## Invariant Check

```
Artifacts/NixBoot/  → Monads/IOMNixBoot/   [OK]
Artifacts/NixDisk/  → (consumed by IOMNixBoot)   [OK]
```
