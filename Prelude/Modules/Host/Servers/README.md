# Servers

Self-hosted services via Podman containers.

**Pattern Version: v1.0.3** | **Structure: FROZEN**

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Host / Servers |
| Purpose | Self-hosted homelab services |
| Targets | nixos (via flake.modules.nixos.servers) |

## Categorical Organization

```
Universe/
├── Data/       # Persistence layer
├── Infra/      # Plumbing layer  
└── Apps/       # Application layer
```

| Layer | Essence | Capabilities |
|-------|---------|--------------|
| **Data** | Storage | ObjectStore, Relational, Documents, Registry, Backup |
| **Infra** | Plumbing | Gateway, Identity, DNS, Metrics, Secrets |
| **Apps** | Services | Git, Media, LLM, Chat |

## Dependency Flow

```
Apps --> Infra --> Data
```

- Apps consume Infra (auth, routing) and Data (storage)
- Infra consumes Data (config persistence)
- Data is foundational (no dependencies)

## Auto-Wiring

Enabling a capability auto-registers it with dependent layers:

| When you enable... | It auto-registers in... |
|--------------------|-------------------------|
| `data.objectStore` | Gateway routes, Metrics scrape targets |
| `apps.git` | Gateway routes, Identity SSO, Backup sources |
| `infra.identity` | All Apps get SSO config |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `flake.modules.nixos.servers` |

## Local Duality (Universe)

### Data Layer

| Feature | Capability | Bindings |
|---------|------------|----------|
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
| `servers.data.<cap>.enable` | bool | false |
| `servers.data.<cap>.backend` | enum | varies |
| `servers.infra.<cap>.enable` | bool | false |
| `servers.apps.<cap>.enable` | bool | false |

## Usage

```nix
# Env/default.nix - enable capabilities
servers = {
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
