# ObjectStore

S3-compatible blob storage capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | Blob/artifact storage via S3 API |
| Bindings | minio, garage, seaweedfs |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable object storage |
| `backend` | enum | "minio" | Storage backend |
| `endpoint` | str | "localhost:9000" | S3 API endpoint |
| `region` | str | "us-east-1" | S3 region |
| `buckets` | listOf str | [] | Buckets to create |
| `persistence.path` | str | "/var/lib/objectstore" | Data directory |

## Usage

```nix
servers.data.objectStore = {
  enable = true;
  backend = "minio";
  buckets = [ "backups" "media" "artifacts" ];
};
```

## Auto-Wiring

When enabled:
- Gateway: `s3.<domain>` route created
- Metrics: Scrape target added
- Backup: Registered as backup source

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| minio | `minio/minio` | Full S3 compatibility |
| garage | `dxflrs/garage` | Distributed, lightweight |
