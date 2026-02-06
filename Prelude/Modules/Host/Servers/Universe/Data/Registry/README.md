# Registry

Container and package artifact storage.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | OCI images, packages |
| Bindings | harbor, gitea-packages |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable registry |
| `backend` | enum | "harbor" | Registry backend |
| `port` | int | 5000 | Registry port |
| `persistence.path` | str | "/var/lib/registry" | Data directory |

## Usage

```nix
servers.data.registry = {
  enable = true;
  backend = "harbor";
};
```

## Auto-Wiring

When enabled:
- Gateway: `registry.<domain>` route created
- Identity: SSO for push/pull
- Backup: Registered as backup source

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| harbor | `goharbor/harbor` | Full-featured |
| distribution | `registry:2` | Minimal OCI |
