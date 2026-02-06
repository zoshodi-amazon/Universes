# Podman

Container runtime layer (internal).

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Runtime |
| Purpose | OCI container execution |
| Consumers | Data, Infra, Apps capabilities |

## Note

This is the low-level runtime used by all higher-level capabilities.
Users should not configure this directly - use Data/Infra/Apps instead.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable Podman runtime |
| `stacks` | attrsOf stack | {} | Container definitions (internal) |

## Internal Usage

Higher-level capabilities (ObjectStore, Gateway, Git, etc.) generate
entries in `servers.podman.stacks` via their Bindings.
