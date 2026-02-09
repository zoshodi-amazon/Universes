# Game

Compositional design lab. 2D pixel art, 3D modeling, audio design, physics simulation, and fabrication -- all terminal-native with live preview.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Labs / Game |
| Purpose | Multidimensional design: 2D, 3D, audio, physics, fabrication |
| Targets | devShells, packages |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports `perSystem.devShells.game`, `perSystem.packages.*` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Core | enable, projectDir | Scripts (init, status) |
| Render | dimension, resolution, backend, palette | Scripts (render) |
| Preview | method, watchExtensions, port | Scripts (watch, serve) |
| Sprite | width, height, palette, frames | Scripts (create, sheet, animate) |
| Audio | (delegates to Labs/Audio) | Scripts (preview, spectrum) |
| Simulate | engine, timeStep, gravity | Scripts (run) |
| Fabricate | format, layerHeight, infill | Scripts (slice, export) |
| Asset | backend, storePath, catalogDb | Scripts (fetch, catalog, list) |

## Options

| Option | Type | Default |
|--------|------|---------|
| `game.enable` | bool | true |
| `game.projectDir` | str | ".lab" |
| `game.render.dimension` | enum 2d/3d | "2d" |
| `game.render.resolution` | str | "320x240" |
| `game.render.backend` | enum aseprite/blender/imagemagick | "aseprite" |
| `game.preview.method` | enum terminal/browser | "terminal" |
| `game.preview.watchExtensions` | list str | ["png" "aseprite" "blend" "json"] |
| `game.preview.port` | port | 8090 |
| `game.sprite.width` | int | 16 |
| `game.sprite.height` | int | 16 |
| `game.sprite.palette` | enum gameboy/nes/pico8/custom | "pico8" |
| `game.fabricate.format` | enum stl/3mf/obj | "stl" |
| `game.asset.backend` | enum local/sqlite | "local" |

## Usage

```bash
cd Modules/Labs/Game

# Initialize workspace
just init

# 2D pixel art
just sprite-create player 16 16          # create sprite
just sprite-sheet player 4               # assemble sheet
just preview                             # live terminal preview

# Audio design
just audio-tone 440 1 sfx/beep.wav       # generate tone
just audio-play sfx/beep.wav             # play in terminal
just audio-spectrum sfx/beep.wav         # visualize spectrum

# 3D (when needed)
just render-3d scene.py                  # blender headless render
just fabricate model.blend stl           # export for 3D printing

# Asset management
just asset-fetch <url> sprite            # fetch into .lab/assets
just asset-list                          # catalog
```
