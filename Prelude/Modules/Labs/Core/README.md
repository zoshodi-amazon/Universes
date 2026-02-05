# Labs/Core

Generic Lab TUI framework for signal processing workstations.

## Overview

| Aspect | Description |
|--------|-------------|
| Purpose | Domain-agnostic Lab TUI framework |
| Pattern | Elm architecture (Model-Update-View) |
| Navigation | Vim-like (h/j/k/l, modes, :commands) |
| Persistence | SQLite with full history |

## Features

| Feature | Capability | Binding |
|---------|------------|---------|
| Library | Asset persistence with undo/redo | sqlite3 |
| Session | Workspace state management | JSON |
| Watch | File change detection | entr |
| Dials | Orthogonal coefficient controls | - |
| TUI | Interactive terminal interface | bubbletea |

## Capability Graph

```
Library (persistence)
    |
    v
Session (state) <---> Dials (coefficients)
    |
    v
TUI (interface) ---> Watch (reactivity)
    |
    v
Domain Justfile (Audio, Video, etc.)
```

## Dials: Orthogonal Basis Representation

Each dial represents a coefficient in an orthogonal basis:

| Internal | Display | Description |
|----------|---------|-------------|
| 0.0-1.0 | Domain-native | Normalized internally, shown in natural units |

Example (Audio):
- Frequency dial: 0.5 internally = 1000Hz displayed (log scale 20Hz-20kHz)
- Volume dial: 0.75 internally = -6dB displayed (linear scale -60dB to 0dB)

## Modes

| Mode | Key | Purpose |
|------|-----|---------|
| BROWSE | b | Navigate library/workspace |
| EDIT | e | Adjust dials |
| PREVIEW | p | Live visualization |
| COMMAND | : | Execute commands |

## Keybindings

| Key | Action |
|-----|--------|
| h/j/k/l | Navigate |
| gg/G | Top/bottom |
| / | Search |
| Enter | Select |
| Esc | Back/cancel |
| q | Quit |
