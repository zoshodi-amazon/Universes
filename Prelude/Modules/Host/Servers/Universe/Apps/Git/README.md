# Git

Code hosting capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Apps |
| Purpose | Git repos, CI/CD, packages |
| Bindings | gitea, forgejo |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable git hosting |
| `backend` | enum | "gitea" | Git backend |
| `domain` | str | "git.localhost" | Git domain |
| `sso` | bool | true | Enable SSO via Identity |
| `actions` | bool | false | Enable CI/CD runners |
| `packages` | bool | false | Enable package registry |

## Usage

```nix
servers.apps.git = {
  enable = true;
  backend = "gitea";
  sso = true;
  actions = true;
};
```

## Auto-Wiring

When enabled:
- Gateway: `git.<domain>` route
- Identity: OIDC client registered
- ObjectStore: LFS/artifacts storage
- Relational: Metadata database
- Backup: Repos backed up

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| gitea | `gitea/gitea` | Lightweight, actions |
| forgejo | `codeberg.org/forgejo/forgejo` | Community fork |
