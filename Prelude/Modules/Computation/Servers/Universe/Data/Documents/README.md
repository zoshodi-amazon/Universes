# Documents

File synchronization capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | Sync files across devices |
| Bindings | syncthing |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable document sync |
| `backend` | enum | "syncthing" | Sync backend |
| `guiPort` | int | 8384 | Web UI port |
| `folders` | attrsOf folder | {} | Folders to sync |
| `devices` | attrsOf device | {} | Trusted devices |

## Usage

```nix
servers.data.documents = {
  enable = true;
  folders.notes = {
    path = "/data/notes";
    devices = [ "laptop" "phone" ];
  };
};
```

## Auto-Wiring

When enabled:
- Gateway: `sync.<domain>` route created
- Backup: Folders registered as backup sources

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| syncthing | `syncthing/syncthing` | P2P, encrypted |
