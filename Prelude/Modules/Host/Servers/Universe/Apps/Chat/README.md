# Chat

Communication capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Layer | Apps |
| Purpose | Messaging, federation |
| Bindings | matrix, mattermost |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | false | Enable chat server |
| `backend` | enum | "matrix" | Chat backend |
| `domain` | str | "chat.localhost" | Chat domain |
| `sso` | bool | true | Enable SSO via Identity |
| `federation` | bool | false | Enable federation |
| `bridges` | listOf bridge | [] | Protocol bridges |

## Usage

```nix
servers.apps.chat = {
  enable = true;
  backend = "matrix";
  federation = true;
  bridges = [ "telegram" "signal" ];
};
```

## Auto-Wiring

When enabled:
- Gateway: `chat.<domain>` route
- Identity: OIDC client registered
- Relational: Message database
- ObjectStore: Media uploads
- Backup: Messages backed up

## Bindings

| Backend | Image | Notes |
|---------|-------|-------|
| matrix | `matrixdotorg/synapse` | Federated, bridges |
| mattermost | `mattermost/mattermost` | Slack-like |
