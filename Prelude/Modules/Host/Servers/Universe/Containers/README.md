# Containers

Container orchestration capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Runtime |
| Purpose | OCI container execution and orchestration |
| Consumers | Data, Infra, Apps capabilities |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | true | Enable container orchestration |
| `backend` | enum | "podman" | Backend: podman, arion |
| `stacks` | attrsOf stack | {} | Container definitions |

## Bindings

| Backend | Implementation |
|---------|----------------|
| podman | virtualisation.podman + oci-containers |
| arion | arion.projects (docker-compose in Nix) |

## Usage

Higher-level capabilities (ObjectStore, Gateway, Git, etc.) generate
entries in `servers.containers.stacks` via their Bindings. Users should
configure capabilities via Data/Infra/Apps, not containers directly.
