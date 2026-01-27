# Browsers

Web browser configuration.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Browsers |
| Purpose | Browser settings and extensions |
| Targets | homeManager |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/Firefox/Options | Exports `flake.modules.homeManager.firefox` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Firefox | enable, defaultBrowser | Plugins (extensions) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `browsers.firefox.enable` | bool | true |
| `browsers.firefox.defaultBrowser` | bool | true |
