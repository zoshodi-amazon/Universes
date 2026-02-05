# Gateway

Reverse proxy and TLS termination capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Infra |
| Purpose | Route traffic, TLS, load balancing |
| Bindings | traefik, caddy |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable gateway |
| `backend` | enum | "traefik" | Proxy backend |
| `domain` | str | "localhost" | Base domain |
| `acme.enable` | bool | false | Enable LetsEncrypt |
| `acme.email` | str | "" | ACME account email |
| `routes` | attrsOf route | {} | Manual routes |

## Usage

```nix
servers.infra.gateway = {
  enable = true;
  backend = "traefik";
  domain = "home.local";
  acme.enable = true;
  acme.email = "admin@example.com";
};
```

## Auto-Wiring

When enabled:
- All Data/Apps services auto-register routes
- Identity: Auth middleware applied
- Metrics: Dashboard exposed

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| traefik | `traefik:v3` | Auto-discovery, middlewares |
| caddy | `caddy:2` | Simple config, auto-HTTPS |
