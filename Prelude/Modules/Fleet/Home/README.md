# Home

Host-level home-manager configurations.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Fleet / Home |
| Purpose | Compose homeConfigurations from flake.modules.homeManager.* |
| Targets | flake.homeConfigurations |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates host options (darwin, cloudDev, cloudNix) | Creates `flake.homeConfigurations.*` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Darwin | username, homeDirectory, stateVersion | enable = true |
| CloudDev | username, homeDirectory, stateVersion | — |
| CloudNix | username, homeDirectory, stateVersion | — |

## Options

| Option | Type | Default |
|--------|------|---------|
| `home.darwin.enable` | bool | true |
| `home.darwin.username` | string | "zoshodi" |
| `home.darwin.homeDirectory` | string | "/Users/zoshodi" |
| `home.cloudDev.enable` | bool | false |
| `home.cloudNix.enable` | bool | false |
