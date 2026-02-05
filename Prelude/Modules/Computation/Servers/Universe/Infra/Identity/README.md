# Identity

Authentication and SSO capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Infra |
| Purpose | Auth, SSO, user directory |
| Bindings | authelia + lldap, keycloak |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable identity |
| `backend` | enum | "authelia" | Auth backend |
| `domain` | str | "auth.localhost" | Auth domain |
| `users` | attrsOf user | {} | User definitions |
| `groups` | attrsOf group | {} | Group definitions |
| `oidc.clients` | attrsOf client | {} | OIDC clients |

## Usage

```nix
servers.infra.identity = {
  enable = true;
  backend = "authelia";
  users.admin = {
    email = "admin@example.com";
    groups = [ "admins" ];
  };
};
```

## Auto-Wiring

When enabled:
- Gateway: Forward auth middleware
- Apps: OIDC client auto-registered
- Secrets: Credentials stored

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| authelia | `authelia/authelia` + `lldap/lldap` | Lightweight, OIDC |
| keycloak | `quay.io/keycloak/keycloak` | Full-featured IAM |
