# Relational

SQL database capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Data |
| Purpose | Structured queryable data |
| Bindings | postgres, mariadb |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable relational database |
| `backend` | enum | "postgres" | Database backend |
| `port` | int | 5432 | Database port |
| `databases` | listOf str | [] | Databases to create |
| `persistence.path` | str | "/var/lib/relational" | Data directory |

## Usage

```nix
servers.data.relational = {
  enable = true;
  backend = "postgres";
  databases = [ "gitea" "authelia" ];
};
```

## Auto-Wiring

When enabled:
- Apps: Connection string injected via env
- Backup: pg_dump scheduled
- Metrics: Exporter scrape target added

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| postgres | `postgres:16-alpine` | Full-featured |
| mariadb | `mariadb:11` | MySQL compatible |
