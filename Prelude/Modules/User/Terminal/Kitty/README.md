# Kitty

GPU-accelerated terminal emulator.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | User / Terminal |
| Purpose | Terminal emulator configuration |
| Targets | homeManager |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/Config/Options | Exports `flake.modules.homeManager.kitty` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Config | enable, font, fontSize, theme | — |

## Options

| Option | Type | Default |
|--------|------|---------|
| `kitty.enable` | bool | true |
| `kitty.font` | string | "JetBrainsMono Nerd Font" |
| `kitty.fontSize` | int | 14 |
| `kitty.theme` | string | "Catppuccin-Mocha" |
