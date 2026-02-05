# Media

Streaming and library capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Apps |
| Purpose | Media streaming, library |
| Bindings | jellyfin, navidrome |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable media server |
| `backend` | enum | "jellyfin" | Media backend |
| `domain` | str | "media.localhost" | Media domain |
| `sso` | bool | true | Enable SSO via Identity |
| `libraries` | attrsOf library | {} | Media libraries |
| `transcoding` | bool | true | Enable transcoding |

## Usage

```nix
servers.apps.media = {
  enable = true;
  backend = "jellyfin";
  libraries.movies = {
    path = "/data/movies";
    type = "movies";
  };
};
```

## Auto-Wiring

When enabled:
- Gateway: `media.<domain>` route
- Identity: OIDC client registered
- ObjectStore: Media file storage
- Backup: Library metadata backed up

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| jellyfin | `jellyfin/jellyfin` | Full media server |
| navidrome | `deluan/navidrome` | Music focused |
