# Universes

Dendritic Nix configuration system.

**Pattern Version: v1.0.3** | **Structure: FROZEN**

---

## Overview

| Aspect | Description |
|--------|-------------|
| Pattern | Dendritic Nix (flake-parts + import-tree) |
| Philosophy | Capability-centric, not tool-centric |
| Structure | Two-level adjunction (Global ⊣ Local) |
| Language | Agnostic (Nix, Python, Rust, etc.) |

---

## Core Dualities

The pattern is built on two adjoint pairs:

### Global Duality (Module-level)

| Env | ⊣ | Instances |
|-----|---|-----------|
| Aggregates Options → ENV vars | | Consumes Env → Nix targets |
| Left adjoint (free) | | Right adjoint (forgetful) |

### Local Duality (Universe-level)

| Options | ⊣ | Bindings |
|---------|---|----------|
| Schema, types, constraints | | Runtime behavior, effects |
| Typeclass (interface) | | Instance (implementation) |

### Options ⊣ Bindings: The Free-Forgetful Adjunction

**CRITICAL**: Options and Bindings must remain decoupled.

| Options (Free/Abstract) | Bindings (Forgetful/Concrete) |
|-------------------------|-------------------------------|
| Vendor-agnostic | Vendor-specific |
| Capability-centric | Implementation-centric |
| "What I want" | "How to get it" |
| `trackingUri` | `MLFLOW_TRACKING_URI` or `WANDB_BASE_URL` |
| `experimentName` | `MLFLOW_EXPERIMENT_NAME` or `WANDB_PROJECT` |

**Anti-pattern** (coupled):
```nix
options.store.mlflow.trackingUri = ...;  # ❌ Vendor in Options
options.store.wandb.project = ...;       # ❌ Vendor in Options
```

**Correct pattern** (decoupled):
```nix
# Options - abstract capability
options.store.trackingUri = ...;      # ✓ Generic
options.store.experimentName = ...;   # ✓ Generic
options.store.backend = enum [ "mlflow" "wandb" "local" ];

# Bindings - concrete mapping per backend
if backend == "mlflow" then MLFLOW_TRACKING_URI = trackingUri
if backend == "wandb" then WANDB_BASE_URL = trackingUri
```

### Options Design Decision Tree

```
Is this field specific to ONE implementation/vendor?
  YES → Does NOT belong in Options, handle in Bindings
  NO ↓

Is this a universal capability concept?
  YES → Add to Options with generic name
  NO ↓

Is it a configuration knob users would want to set?
  YES → Add to Options
  NO → Hardcode in Bindings or derive from other Options
```

---

## Categorical Organization

```
Modules/
├── Computation/    # Process: interpreters, editors, services
├── Information/    # Symbol: code, docs, databases  
├── Physical/       # Matter: hardware, materials
└── Signal/         # Wave: audio, video, electrical
```

### Category Boundaries

| Category | Essence | Ontological Status | Examples |
|----------|---------|-------------------|----------|
| **Computation** | Process | Transformation over time | Interpreters, editors, services, VMs |
| **Information** | Symbol | Structured representation | Code, docs, databases, git |
| **Physical** | Matter | Tangible substrate | Hardware, materials, devices |
| **Signal** | Wave | Continuous transmission | Audio, video, telemetry, streams |

### Boundary Distinctions

| Boundary | Distinction |
|----------|-------------|
| Computation ↔ Information | Process vs Data. Computation *acts on* Information. |
| Information ↔ Signal | Discrete vs Continuous. Symbols vs Waveforms. |
| Signal ↔ Physical | Transmission vs Substrate. Signal travels *through* Physical. |
| Physical ↔ Computation | Hardware vs Software. Physical runs Computation. |

### Category Decision Tree

```
Is it a transformation/process that acts on data?
  YES → Computation/
  NO ↓

Is it structured, discrete, stored representation?
  YES → Information/
  NO ↓

Is it continuous transmission/streaming?
  YES → Signal/
  NO ↓

Is it tangible hardware/material?
  YES → Physical/
```

### Quick Reference

| Thing | Category | Why |
|-------|----------|-----|
| Neovim, shells | Computation | Transforms text (process) |
| Git repo, configs | Information | Stores symbols (data) |
| OTEL, Prometheus | Signal | Telemetry streams |
| GPU, sensors | Physical | Hardware substrate |
| Log *file* | Information | Discrete, stored |
| Log *stream* | Signal | Continuous, transmitted |
| Trained model file | Information | Static artifact |
| Inference stream | Signal | Real-time transmission |
| Training loop | Computation | Process over time |

---

## Module Structure

Every module follows this frozen structure:

```
<Module>/
├── README.md           # Documentation (this template)
├── default.nix         # Tensor (empty, import-tree entry)
├── Env/                # Global: ENV var aggregation
├── Instances/          # Global: flake.modules.* exports
├── Drv/                # Optional: custom derivations
│   └── <package>/      # One subdir per package
│       └── default.nix # buildPythonPackage, mkDerivation, etc.
└── Universe/           # Local: feature microcosm
    └── <Feature>/
        ├── Options/    # Schema (default.nix ≅ index.<lang>)
        └── Bindings/   # Effects (Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins)
```

### Drv/ Structure

For custom derivations (when nixpkgs is broken/outdated):

```
Drv/
├── default.nix         # Empty tensor (import-tree entry)
├── mlflow/
│   └── default.nix     # buildPythonPackage { pname = "mlflow"; ... }
├── sb3/
│   └── default.nix     # buildPythonPackage { pname = "stable-baselines3"; ... }
└── <package>/
    └── default.nix
```

Each `Drv/<package>/default.nix` exports to `perSystem.packages.<package>`.

---

## Invariants

```
1. Every .nix file is a flake-parts module
2. Every Module has: README.md, default.nix, Env/, Instances/, Universe/
3. Every Universe/<Feature> has: Options/, Bindings/
4. Universe/<Feature> = sub-object classifier of the capability space
5. Options = type (possibility space), Bindings = terms (inhabitants)
6. Bindings/ ⊆ {Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins}
7. Env/ aggregates Universe/*/Options → ENV vars
8. Instances/ consumes config generically (no manual enumeration)
9. NO manual imports (import-tree auto-imports)
10. File naming: default.* only
11. Standard scripting: Nushell (default.nu)
12. Modules enable themselves: if created, capability is desired
```

---

## Language Agnosticism

Options can be defined in any language:

| Language | File | Manifest |
|----------|------|----------|
| Nix | `default.nix` | — |
| Python | `index.py` | `pyproject.toml` |
| Rust | `index.rs` | `Cargo.toml` |
| TypeScript | `index.ts` | `package.json` |

The isomorphism:
```
Options/default.nix ≅ Options/index.<lang> ≅ ENV vars ≅ CLI flags
```

---

## Targets

| Target | Scope | Purpose |
|--------|-------|---------|
| `flake.modules.homeManager.*` | User | Home-manager modules |
| `flake.modules.nixos.*` | System | NixOS modules |
| `flake.modules.darwin.*` | System | nix-darwin modules |
| `perSystem.devShells.*` | Dev | Development environments |
| `perSystem.packages.*` | Build | Derivations |
| `perSystem.checks.*` | CI | Validation |

---

## Bindings Categories

| Category | Signature | Purpose |
|----------|-----------|---------|
| Scripts | `() → Effect` | Entry points (default.nu) |
| Commands | `Cmd → Effect` | CLI commands |
| Keymaps | `Key → Action` | Input bindings |
| Hooks | `Event → Effect` | Lifecycle (Init, Save, Load, Log, Sync, Cleanup) |
| State | `S → S` | State machines |
| Secrets | `Path → Value` | Sensitive data |
| Plugins | `Base → Extended` | Extensions |

---

## Modules

### Computation

| Module | Purpose | Targets |
|--------|---------|---------|
| [Browsers](Prelude/Modules/Computation/Browsers/) | Web browsing | homeManager |
| [Checks](Prelude/Modules/Computation/Checks/) | Linting, invariants | devShells, checks |
| [Editor](Prelude/Modules/Computation/Editor/) | Text editing | homeManager |
| [Home](Prelude/Modules/Computation/Home/) | Host configurations | homeConfigurations |
| [Network](Prelude/Modules/Computation/Network/) | Networking | homeManager |
| [Servers](Prelude/Modules/Computation/Servers/) | Containers | nixos |
| [Services](Prelude/Modules/Computation/Services/) | Long-running | devShells, packages |
| [Terminal](Prelude/Modules/Computation/Terminal/) | Shell, Tmux, Kitty | homeManager |
| [Virtualization](Prelude/Modules/Computation/Virtualization/) | VMs | nixos |

### Information

| Module | Purpose | Targets |
|--------|---------|---------|
| [Persist/Git](Prelude/Modules/Information/Persist/Git/) | Version control | homeManager |

---

## Wrapping External Packages

### Decision Tree

```
Does the repo have a flake.nix?
  YES → Add to inputs, use outputs directly
  NO ↓

Is it in nixpkgs?
  YES → Use pkgs.<name>
  NO ↓

Fetch and build derivation:
  fetchFromGitHub + mkDerivation/buildPythonPackage/etc.
```

### Strategy 1: Flake Input (preferred)

```nix
# flake.nix inputs
inputs.cool-tool.url = "github:owner/cool-tool";

# In module
{ inputs, ... }: {
  config.perSystem = { system, ... }: {
    packages.cool-tool = inputs.cool-tool.packages.${system}.default;
  };
}
```

### Strategy 2: Nixpkgs

```nix
{ pkgs, ... }: {
  home.packages = [ pkgs.cool-tool ];
}
```

### Strategy 3: Custom Derivation

```nix
{ pkgs, ... }:
let
  cool-tool = pkgs.stdenv.mkDerivation {
    pname = "cool-tool";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "owner";
      repo = "cool-tool";
      rev = "v1.0.0";
      sha256 = "sha256-AAAA...";
    };
    # buildInputs, installPhase, etc.
  };
in { home.packages = [ cool-tool ]; }
```

### Wrapping as Module

Once you have the package, wrap it by mapping its configuration surface:

```
1. Discover   → <tool> --help, env | grep TOOL_, cat ~/.config/tool/*
2. Map        → CLI flags / ENV vars / config files → Options
3. Wire       → Options → ENV vars or config file generation
```

Example:

```nix
# Universe/Core/Options/default.nix
options.coolTool = {
  enable = lib.mkEnableOption "cool-tool";
  port = lib.mkOption { type = lib.types.port; default = 8080; };
  logLevel = lib.mkOption { type = lib.types.enum ["debug" "info" "warn"]; default = "info"; };
};

# Instances/default.nix  
config.coolTool.enable = lib.mkDefault true;
config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
  devShells.cool-tool = pkgs.mkShell {
    packages = [ pkgs.cool-tool ];
    shellHook = ''
      export COOL_TOOL_PORT="${toString cfg.port}"
      export COOL_TOOL_LOG_LEVEL="${cfg.logLevel}"
    '';
  };
};
```

### Configuration Surface Isomorphism

All configuration mechanisms are equivalent:

```
CLI flags    ≅  ENV vars      ≅  Config files    ≅  Options/default.nix
--port=8080  ≅  PORT=8080     ≅  port: 8080      ≅  port = 8080;
--verbose    ≅  VERBOSE=true  ≅  verbose: true   ≅  verbose = true;
```

Pick whichever the tool supports best, wire in Instances.

---

## Usage

```bash
# Check all invariants
nix flake check

# Build darwin home configuration
nix build .#homeConfigurations.darwin.activationPackage

# Switch to configuration
home-manager switch --flake .#darwin

# Enter dev shell
nix develop .#checks
```

---

## Flake Integration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } 
    (inputs.import-tree ./Modules);
}
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v1.0.3 | 2026-01-27 | README.md required, Nushell standard, file naming |
| v1.0.2 | 2026-01-27 | Plugins in Bindings/, 7 binding types |
| v1.0.1 | 2026-01-27 | default.nix naming |
| v1.0.0 | 2026-01-27 | Frozen structure, two-level adjunction |

---

## Notes

Common pitfalls and lessons learned:

| Issue | Solution |
|-------|----------|
| Nix float literals like `3e-4` fail | Use `lib.types.str` with `"3e-4"`, parse in binding |
| Cross-platform checks fail on wrong system | Use `--system` flag or filter hosts by `system` |
| Module not exported to `flake.modules.*` | Ensure `<module>.enable = true` in Bindings |
| Infinite recursion with `mkIf cfg.enable` | Don't set `x.enable` inside `mkIf x.enable` block |
| Where to set `<module>.enable = true` | Global: `Instances/`, Local features: `Universe/<Feature>/Bindings/` |
| Package not building | Always `nix search nixpkgs <pkg>` or `nix eval nixpkgs#<pkg>.pname` first |
| Python ML packages (tf, mlflow, sb3) | Create custom derivation in `Drv/` rather than fight nixpkgs versions |

---

**Pattern Version: v1.0.3** | **Structure: FROZEN** | **Expressiveness: Universe/**
