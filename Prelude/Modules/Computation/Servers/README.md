# Servers

Container-based server stacks via Podman and Arion.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Servers |
| Purpose | OCI container orchestration |
| Targets | nixos |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `flake.modules.nixos.{podman,arion}` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Podman | enable, stacks, dockerCompat | Scripts |
| Arion | enable, projects | — |

## Options

| Option | Type | Default |
|--------|------|---------|
| `servers.podman.enable` | bool | false |
| `servers.podman.stacks` | attrsOf stack | {} |
| `servers.arion.enable` | bool | false |
| `servers.arion.projects` | attrsOf module | {} |
