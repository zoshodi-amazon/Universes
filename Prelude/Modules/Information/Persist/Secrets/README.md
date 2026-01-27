# Secrets

Encrypted secrets management via sops-nix.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Information / Persist |
| Purpose | Store encrypted secrets in git, decrypt at activation |
| Targets | homeManager, nixos |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/Sops/Options | Exports `flake.modules.{homeManager,nixos}.secrets` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Sops | enable, defaultSopsFile, age.keyFile | Scripts (edit, rotate) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `secrets.sops.enable` | bool | true |
| `secrets.sops.defaultSopsFile` | path | ./secrets.yaml |
| `secrets.sops.age.keyFile` | path | ~/.config/sops/age/keys.txt |

## Usage

```bash
# Create/edit secrets
sops secrets.yaml

# Secrets available at runtime as files
config.sops.secrets."my-secret".path
```
