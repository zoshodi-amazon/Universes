# Game

Game engine service with reinforcement learning integration.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Labs / Game |
| Purpose | Game loop, input handling, rendering pipeline |
| Targets | devShells, packages |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `perSystem.devShells.game`, `perSystem.packages.game` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Core | enable, tickRate | Scripts (main), Commands, Hooks (Init, Save, Load) |
| Input | enable, inputMap | Keymaps, State |
| Render | enable, backend | Plugins (shaders) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `game.enable` | bool | false |
| `game.tickRate` | int | 60 |
| `game.input.enable` | bool | true |
| `game.render.enable` | bool | true |
| `game.render.backend` | string | "vulkan" |
