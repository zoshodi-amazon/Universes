# Servers

Self-hosted services via container orchestration.

**Pattern Version: v1.0.5** | **Structure: FROZEN**

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Host / Servers |
| Purpose | Self-hosted homelab services |
| Targets | nixos (via flake.modules.nixos.servers) |

## Categorical Organization

```
Universe/
├── Containers/ # Runtime layer (podman, arion)
├── Data/       # Persistence layer
├── Infra/      # Plumbing layer
└── Apps/       # Application layer
```

| Layer | Essence | Capabilities |
|-------|---------|--------------|
| **Containers** | Runtime | Container orchestration (backend: podman, arion) |
| **Data** | Storage | Persistence, ObjectStore, Relational, Documents, Registry, Backup |
| **Infra** | Plumbing | Gateway, Identity, DNS, Metrics, Secrets |
| **Apps** | Services | Git, Media, LLM, Chat |

## Dependency Flow

```
Apps --> Infra --> Data --> Containers
```

- Apps consume Infra (auth, routing) and Data (storage)
- Infra consumes Data (config persistence)
- Data is foundational storage capabilities
- Containers is the runtime layer all others bind to

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `flake.modules.nixos.servers` |

## Local Duality (Universe)

### Containers Layer

| Feature | Capability | Bindings |
|---------|------------|----------|
| Containers | Container orchestration | podman, arion |

### Data Layer

| Feature | Capability | Bindings |
|---------|------------|----------|
| Persistence | Cross-module storage backend | local (SQLite), s3, postgres |
| ObjectStore | S3-compatible blob storage | minio, garage |
| Relational | SQL databases | postgres, mariadb |
| Documents | File synchronization | syncthing |
| Registry | Container/package artifacts | harbor |
| Backup | Point-in-time snapshots | borgbackup, restic |

### Infra Layer

| Feature | Capability | Bindings |
|---------|------------|----------|
| Gateway | Reverse proxy + TLS | traefik, caddy |
| Identity | Auth + SSO | authelia + lldap |
| DNS | Name resolution | coredns, pihole |
| Metrics | Observability | prometheus + grafana |
| Secrets | Credential management | vault |

### Apps Layer

| Feature | Capability | Bindings |
|---------|------------|----------|
| Git | Code hosting | gitea, forgejo |
| Media | Streaming/library | jellyfin |
| LLM | Local inference | ollama |
| Chat | Communication | matrix |

## Options

| Option | Type | Default |
|--------|------|---------|
| `servers.containers.enable` | bool | true |
| `servers.containers.backend` | enum | "podman" |
| `servers.containers.stacks` | attrsOf stack | {} |
| `servers.data.<cap>.enable` | bool | varies |
| `servers.infra.<cap>.enable` | bool | false |
| `servers.apps.<cap>.enable` | bool | false |

## Usage

```nix
servers = {
  containers.backend = "podman";
  infra.gateway.enable = true;
  infra.identity.enable = true;
  data.objectStore.enable = true;
  apps.git.enable = true;
};
```

## Commands

```bash
just servers-status    # Show enabled services
just servers-logs git  # Tail logs for a service
```
