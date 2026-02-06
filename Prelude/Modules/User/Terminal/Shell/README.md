# Shell

Interactive shell configuration (Fish, Nushell, Direnv).

## Capability

| Aspect | Description |
|--------|-------------|
| Category | User / Terminal |
| Purpose | Shell environments and environment management |
| Targets | homeManager |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates shell feature options | Exports `flake.modules.homeManager.{fish,nushell,direnv}` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Fish | enable, plugins | Plugins (starship, fzf) |
| Nushell | enable, configPath | Plugins |
| Direnv | enable, enableFishIntegration | — |

## Options

| Option | Type | Default |
|--------|------|---------|
| `shell.fish.enable` | bool | true |
| `shell.nushell.enable` | bool | false |
| `shell.direnv.enable` | bool | true |
