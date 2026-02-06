# DNS

Name resolution capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Infra |
| Purpose | Local DNS, ad blocking |
| Bindings | coredns, pihole |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable DNS |
| `backend` | enum | "coredns" | DNS backend |
| `domain` | str | "home.local" | Local domain |
| `upstream` | listOf str | ["1.1.1.1"] | Upstream resolvers |
| `records` | attrsOf record | {} | Static records |
| `adblock` | bool | false | Enable ad blocking |

## Usage

```nix
servers.infra.dns = {
  enable = true;
  backend = "coredns";
  domain = "home.local";
  adblock = true;
};
```

## Auto-Wiring

When enabled:
- Gateway: DNS resolution for services
- All services: Local domain resolution

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| coredns | `coredns/coredns` | Lightweight, plugins |
| pihole | `pihole/pihole` | Ad blocking, UI |
