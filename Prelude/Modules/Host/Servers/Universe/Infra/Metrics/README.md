# Metrics

Observability capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Infra |
| Purpose | Metrics, logs, dashboards |
| Bindings | prometheus + grafana, victoria |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable metrics |
| `backend` | enum | "prometheus" | Metrics backend |
| `retention` | str | "15d" | Data retention |
| `scrapeTargets` | listOf target | [] | Additional scrape targets |
| `alertRules` | attrsOf rule | {} | Alert rules |

## Usage

```nix
servers.infra.metrics = {
  enable = true;
  backend = "prometheus";
  retention = "30d";
};
```

## Auto-Wiring

When enabled:
- All services: Scrape targets auto-discovered
- Gateway: Dashboard exposed
- Identity: SSO for Grafana

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| prometheus | `prom/prometheus` + `grafana/grafana` | Standard stack |
| victoria | `victoriametrics/victoria-metrics` | Resource efficient |
