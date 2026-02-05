# Servers/Storage

Global persistence capability for cross-module/cross-machine storage.

## Overview

| Aspect | Description |
|--------|-------------|
| Purpose | Global storage backend (swap local SQLite for remote) |
| Backends | local (SQLite), s3 (minio), postgres |
| Pattern | Modules set `backend` + `remote.url` to use global storage |

## Usage

Local (default):
```nix
storage.backend = "local";
storage.local.path = ".lab/library.db";
```

Remote (S3):
```nix
storage.backend = "s3";
storage.remote.url = "http://minio.local:9000";
storage.remote.bucket = "lab-assets";
```

Remote (Postgres):
```nix
storage.backend = "postgres";
storage.remote.url = "postgres://user@host/db";
```
