# Persistence

Cross-module storage backend selection.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | Global storage backend (swap local SQLite for remote) |
| Backends | local (SQLite), s3 (minio), postgres |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `backend` | enum | "local" | local, s3, postgres |
| `local.path` | str | ".lab/storage.db" | Local SQLite path |
| `remote.url` | str | "" | Remote storage URL |
| `remote.bucket` | str | "" | S3 bucket name |
| `remote.credentials` | str | "" | Credentials path |

## Usage

Local (default):
```nix
servers.data.persistence.backend = "local";
servers.data.persistence.local.path = ".lab/library.db";
```

Remote (S3):
```nix
servers.data.persistence.backend = "s3";
servers.data.persistence.remote.url = "http://minio.local:9000";
servers.data.persistence.remote.bucket = "lab-assets";
```
