# Backup

Point-in-time snapshot capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | Scheduled backups, restore |
| Bindings | borgbackup, restic |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable backups |
| `backend` | enum | "borgbackup" | Backup backend |
| `schedule` | str | "daily" | Backup frequency |
| `retention.daily` | int | 7 | Daily snapshots to keep |
| `retention.weekly` | int | 4 | Weekly snapshots to keep |
| `retention.monthly` | int | 6 | Monthly snapshots to keep |
| `targets` | listOf target | [] | Remote backup targets |

## Usage

```nix
servers.data.backup = {
  enable = true;
  backend = "borgbackup";
  schedule = "daily";
  targets = [{
    type = "s3";
    bucket = "backups";
  }];
};
```

## Auto-Wiring

When enabled:
- ObjectStore: Snapshots stored
- Relational: pg_dump scheduled
- Documents: Folders backed up
- Apps: Data directories included

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| borgbackup | `borgbackup/borgbackup` | Deduplication, encryption |
| restic | `restic/restic` | Fast, multi-backend |
