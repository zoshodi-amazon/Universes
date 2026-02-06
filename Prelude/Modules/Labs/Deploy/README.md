# Deploy

Remote deployment via deploy-rs.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Labs / Deploy |
| Purpose | Push NixOS/home-manager configs to remote hosts |
| Targets | flake.deploy |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/DeployRS/Options | Exports `flake.deploy.nodes.*` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| DeployRS | enable, nodes, sshUser | Scripts (deploy, rollback) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `deploy.enable` | bool | false |
| `deploy.nodes` | attrsOf node | {} |
| `deploy.sshUser` | string | "root" |

## Usage

```bash
# Deploy to all nodes
deploy .

# Deploy to specific node
deploy .#myhost

# Check what would be deployed
deploy --dry-activate .
```
