# Cloud

AWS CLI profile management via home-manager `programs.awscli`.

## Structure

```
Cloud/
├── Types/
│   ├── NixCloud/default.nix     # Options (enable, defaultRegion, defaultOutput, profiles)
│   └── default.nix
├── Monads/
│   ├── IOMNixCloud/default.nix  # Default Conduit profile
│   └── default.nix
├── default.nix                  # → flake.modules.homeManager.cloud
└── README.md
```

## IO Boundary

- `~/.aws/config` — managed declaratively by Nix (Solid)
- `~/.aws/credentials` — filled at runtime by `ada credentials update` (IO/ephemeral)

## Usage

Credentials are ephemeral — run at runtime:

```bash
ada credentials update --account=043309350576 --provider=conduit --role=IibsAdminAccess-DO-NOT-DELETE --once
```

## Invariant Check

```
Types/NixCloud/  → Monads/IOMNixCloud/   [OK]
```
