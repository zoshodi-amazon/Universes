# Nix

Nix daemon and store optimization capability space.

## Capability Space

System-level Nix configuration: caching, garbage collection, store optimization.

## Sum Types (Universe/)

| Feature | Purpose |
|---------|---------|
| Core | Daemon settings, GC, caching |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| enable | bool | false | Enable Nix optimizations |
| gc.automatic | bool | true | Auto garbage collection |
| gc.interval | str | "weekly" | GC frequency |
| gc.olderThan | str | "7d" | Delete older generations |
| optimise | bool | true | Hard-link deduplication |
| maxJobs | int/auto | "auto" | Parallel build jobs |
| cores | int | 0 | Cores per build (0=all) |

## Targets

| Target | Scope |
|--------|-------|
| flake.modules.homeManager.nix-settings | User |
| flake.modules.nixos.nix-settings | System |
| flake.modules.darwin.nix-settings | System |
