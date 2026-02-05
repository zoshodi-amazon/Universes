# Labs/TUI

Domain-agnostic workbench framework for fast iteration.

## Overview

| Aspect | Description |
|--------|-------------|
| Purpose | Universal Lab TUI framework |
| Pattern | Capability-indexed, self-contained |
| Stack | nushell + gum + tmux + justfile |
| Storage | SQLite (local) / S3/Postgres (remote) |

## Capability Graph

```
CORE CAPABILITIES
-----------------
Storage   - CRUD, history, query, export
Metrics   - Collect, aggregate, compare, alert
Logs      - Stream, filter, search, persist
Preview   - Live view, multi-mode, split panes

INTERACTION LAYER
-----------------
Knobs     - Orthogonal transforms, explore/commit
Session   - Current artifact, stack, undo/redo
Presets   - Global / Domain / User (Zoo hierarchy)
Layout    - Tmux presets (explore, compare, export, monitor)

DOMAIN LAYER (Swappable)
------------------------
Transforms - Domain-specific operations
Overlays   - Domain-specific visualizations
Bindings   - Domain-specific tools (ffmpeg, openscad, etc.)
```

## Core Capabilities

### Storage
Persistence layer with full history.

| Operation | Description |
|-----------|-------------|
| Create | Add new artifact |
| Read | Query artifacts |
| Update | Modify artifact |
| Delete | Remove artifact |
| History | Full undo/redo |
| Export | Output to external format |

### Metrics
Lightweight measurement and comparison.

| Operation | Description |
|-----------|-------------|
| Collect | Gather metrics from artifacts |
| Aggregate | Sum, avg, min, max, histogram |
| Compare | Diff against baseline |
| Alert | Threshold notifications |

### Logs
Observability and debugging.

| Operation | Description |
|-----------|-------------|
| Stream | Live tail |
| Filter | Pattern matching |
| Search | Full-text search |
| Persist | Save to storage |

### Preview
Real-time visualization.

| Mode | Description |
|------|-------------|
| Primary | Single artifact view |
| Split | Side-by-side comparison |
| Diff | Highlight differences |

### Knobs
Orthogonal transform controls.

| Phase | Description |
|-------|-------------|
| Explore | Interactive adjustment with live preview |
| Adjust | Fine-tune parameters |
| Preview | See effect before commit |
| Commit | Freeze to new artifact |

### Session
Workspace state management.

| State | Description |
|-------|-------------|
| Current | Active artifact ID |
| Stack | Uncommitted transforms |
| Mode | explore / compare / export / monitor |
| Undo | Position in history |

### Presets (Zoo)
Hierarchical preset library.

| Level | Location | Scope |
|-------|----------|-------|
| Global | Labs/TUI/Universe/Presets/ | All domains |
| Domain | Labs/<Domain>/Universe/Presets/ | Domain-specific |
| User | .lab/presets/ | Personal |

### Layout
Tmux pane presets.

| Preset | Layout | Use Case |
|--------|--------|----------|
| explore | preview/knobs + library/logs | Interactive creation |
| compare | preview-a/preview-b + metrics | A/B comparison |
| export | preview + settings/logs | Final render |
| monitor | metrics/logs + alerts | Observation |

## Tmux Layouts

### Explore Mode
```
+-------------+-------------+
|   PREVIEW   |    KNOBS    |
+-------------+-------------+
|   LIBRARY   |    LOGS     |
+-------------+-------------+
```

### Compare Mode
```
+-------------+-------------+
|  PREVIEW A  |  PREVIEW B  |
+---------------------------+
|          METRICS          |
+---------------------------+
```

### Export Mode
```
+---------------------------+
|          PREVIEW          |
+-------------+-------------+
|  SETTINGS   |    LOGS     |
+-------------+-------------+
```

### Monitor Mode
```
+---------------------------+
|          METRICS          |
+-------------+-------------+
|    LOGS     |   ALERTS    |
+-------------+-------------+
```

## Self-Contained Guarantee

Every Lab is fully self-contained:

| Guarantee | Implementation |
|-----------|----------------|
| No external refs | All data in `.lab/` |
| No context switch | All ops via justfile |
| No manual setup | `just lab` bootstraps |
| Portable | Copy `.lab/` to move workspace |

## Usage

```bash
# Launch Lab TUI
just lab audio

# Initialize storage
just init-storage

# Add artifact
just add "name" /path/to/file

# List artifacts
just list

# Apply transform
just transform pitch +3

# Export
just export output.wav
```

## Domain Extension

To create a new domain Lab:

1. Create `Labs/<Domain>/` with standard module structure
2. Define domain transforms in `Universe/Transforms/`
3. Define domain overlays in `Universe/Overlays/`
4. Define domain bindings in `Universe/Bindings/`
5. Create justfile inheriting from TUI

The framework (Storage, Metrics, Logs, Preview, Knobs, Session, Presets, Layout) is inherited automatically.
