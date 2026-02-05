# AGENTS.md

Agent-optimized context for the Universes Prelude repository.

Pattern Version: v1.0.3 | Structure: FROZEN

## Philosophy

This is a capability-centric, vendor-agnostic Nix configuration system. The core insight:

**Index on CAPABILITY, not IMPLEMENTATION.**

When you think "I need to configure tmux", reframe as "I need terminal multiplexing capability." The tool is incidental; the capability is essential.

**Minimize the generating set of capabilities.**

Prefer tools that span multiple capabilities over single-purpose tools. Only introduce new dependencies if existing tools cannot cover the capability. Example: ffmpeg provides audio/video playback, spectrum visualization, waveform rendering, format conversion - use it instead of adding cava, sox, and separate converters.

**New dependency rule:** Add a tool IF AND ONLY IF no existing tool covers the capability.

**TUI = justfile + gum.** That's it. No additional frameworks needed. gum provides interactive prompts (choose, input, filter, confirm, spin, style, table), justfile provides recipes. Together they form a complete interactive terminal interface.

## Core Adjunctions

The pattern is built on two adjoint pairs (free-forgetful adjunctions):

### Global Duality (Module-level)

```
Env ⊣ Instances
```

- Env: Aggregates Options into ENV vars (left adjoint, free)
- Instances: Consumes Env, exports to Nix targets (right adjoint, forgetful)

### Local Duality (Universe-level)

```
Options ⊣ Bindings
```

- Options: Schema, types, constraints (interface/typeclass)
- Bindings: Runtime behavior, effects (implementation/instance)

### The Critical Decoupling

Options and Bindings MUST remain decoupled:

| Options (Abstract) | Bindings (Concrete) |
|--------------------|---------------------|
| Vendor-agnostic | Vendor-specific |
| Capability-centric | Implementation-centric |
| "What I want" | "How to get it" |
| `trackingUri` | `MLFLOW_TRACKING_URI` or `WANDB_BASE_URL` |

## Categorical Organization

```
Modules/
├── Computation/    # Process: transformation over time
├── Information/    # Symbol: structured representation
├── Labs/           # Workstation: signal processing environments
└── Physical/       # Matter: tangible substrate
```

### Category Decision Tree

```
Is it a transformation/process that acts on data?
  YES -> Computation/
  NO  |
      v
Is it structured, discrete, stored representation?
  YES -> Information/
  NO  |
      v
Is it signal processing / waveform manipulation?
  YES -> Labs/
  NO  |
      v
Is it tangible hardware/material?
  YES -> Physical/
```

### Boundary Distinctions

| Boundary | Distinction |
|----------|-------------|
| Computation <-> Information | Process vs Data. Computation acts on Information. |
| Information <-> Labs | Discrete symbols vs Continuous signals. |
| Labs <-> Physical | Signal processing vs Hardware substrate. |
| Physical <-> Computation | Hardware vs Software. Physical runs Computation. |

### Quick Reference

| Thing | Category | Why |
|-------|----------|-----|
| Neovim, shells, VMs | Computation | Transforms data (process) |
| Git repo, configs, docs | Information | Stores symbols (data) |
| Audio workstation | Labs | Signal processing environment |
| GPU, sensors, USB | Physical | Hardware substrate |
| Log file | Information | Discrete, stored |
| Audio synthesis | Labs | Signal generation |

## Invariants

MUST NEVER VIOLATE:

1. Every `.nix` file is a flake-parts module
2. Every Module has: README.md, default.nix, Env/, Instances/, Universe/
3. Every Universe/Feature has: Options/, Bindings/
4. File naming: `default.*` only (default.nix, default.nu, default.py)
5. NO manual imports (import-tree auto-imports)
6. NO vendor names in Options (handle in Bindings)
7. NO emojis in code or documentation
8. Standard scripting: Nushell ONLY (default.nu) - NO bash, NO sh, NO zsh
9. Modules enable themselves: if created, capability is desired
10. All shell commands go through justfile with man-page documentation
11. Options define capability space (types), Bindings define term space (inhabitants)
12. Bindings subdirs limited to: Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins
13. Options/default.nix is single source of truth for all schema
14. Scripts are interpreters of Options, not imperative commands
15. NO hidden CLI params - all configuration explicit in Options
16. Justfile recipes use `#!/usr/bin/env nu` shebang when multi-line
17. All nushell scripts strongly typed - explicit annotations, no implicit conversions

## Capability Discovery & Freezing

Tool selection is a statistical best-fit problem:

### Discovery Process
1. **Define** - Enumerate required capabilities with weights
2. **Search** - Find candidates (nixpkgs, flakes, codegraph)
3. **Score** - Evaluate capability coverage per candidate
4. **Select** - Choose minimal set (no over/underfit)
5. **Freeze** - Document in Options, never revisit without cause

### Fit Score
```
score(tool) = sum(weight_i * has_capability_i) / sum(weight_i)
```
Select tool with highest score that satisfies all `required = true`.

## Storage as Capability

| Scope | Capabilities | Binding |
|-------|--------------|---------|
| Local (module) | speed, interop, query | SQLite (nushell native) |
| Global (system) | persistence, sharing, versioning | Self-hosted (Servers/Storage) |

Modules configure `db_path` for local SQLite. Swap to remote by setting `backend = "s3"` or `"postgres"` with `remote.url`.

## Anti-Patterns

### Vendor in Options (WRONG)

```nix
options.store.mlflow.trackingUri = ...;  # NO: vendor in Options
options.store.wandb.project = ...;       # NO: vendor in Options
```

### Capability in Options (CORRECT)

```nix
options.store.trackingUri = ...;         # YES: generic capability
options.store.experimentName = ...;      # YES: generic capability
options.store.backend = enum [ "mlflow" "wandb" "local" ];
```

### Tool-Indexed Thinking (WRONG)

"I need to set up tmux, then configure zsh, then install neovim..."

### Capability-Indexed Thinking (CORRECT)

"I need: terminal multiplexing, shell environment, text editing..."

### Broken Binding Blocks Capability (WRONG)

```nix
# NO: capability blocked because specific tool is broken
"cava"  # broken in nixpkgs, so no spectrum visualization
```

### Swap Binding, Preserve Capability (CORRECT)

```nix
# YES: capability preserved, binding swapped
# Capability: spectrum visualization
# Binding options: cava, cli-visualizer, vis
"cli-visualizer"  # cava broken, swap to alternative
```

### Hidden CLI Params in Scripts (WRONG)

```nu
# NO: imperative params hidden in script
def main [input: string, --highpass: int, --pitch: int] {
  ffmpeg -i $input -af $"highpass=($highpass)" ...
}
```

### Pure Data Options with Interpreter (CORRECT)

```nix
# Options/default.nix - pure data schema
options.audio.transforms = lib.mkOption {
  type = lib.types.listOf transformType;
};
```

```nu
# Bindings/Scripts/default.nu - interpreter reads Options
def main [config_path: string] {
  let cfg = (open $config_path)
  # interpret cfg.transforms into ffmpeg calls
}
```

## Module Structure

See `Docs/TEMPLATE.md` for the frozen structure.

```
<Module>/
├── README.md           # Capability documentation
├── default.nix         # Empty tensor (import-tree entry)
├── Env/                # Options -> ENV vars
├── Instances/          # Env -> flake targets
└── Universe/
    └── <Feature>/
        ├── Options/    # Type space (capability schema)
        └── Bindings/   # Term space (implementation)
```

## Options Design Decision Tree

```
Is this field specific to ONE implementation/vendor?
  YES -> Does NOT belong in Options, handle in Bindings
  NO  |
      v
Is this a universal capability concept?
  YES -> Add to Options with generic name
  NO  |
      v
Is it a configuration knob users would want to set?
  YES -> Add to Options
  NO  -> Hardcode in Bindings or derive from other Options
```

## Iteration Workflow

### 1. Introspect

```bash
just modules                              # List all modules
just features Modules/Computation/Terminal # List features in module
just options Modules/Computation/Terminal  # Show capability space
```

### 2. Create

```bash
just new-module Modules/Computation/Foo    # Scaffold new module
just new-feature Modules/Computation/Foo Bar # Add feature to module
```

### 3. Build

```bash
just check                                 # Validate flake
just build sovereignty                     # Build machine image
```

### 4. Deploy

```bash
just flash sovereignty /dev/disk4          # Flash to USB
just ssh sovereignty                       # Connect to machine
```

## Justfile Commands

Thin interface to scripts in `Modules/Computation/Scripts/Universe/*/Bindings/Scripts/`.

### Introspect

| Command | Purpose | Script |
|---------|---------|--------|
| `just modules` | List all modules | Discover/default.nu |
| `just features <module>` | List Universe features | Introspect/features.nu |
| `just options <module>` | Show Options type space | Introspect/default.nu |
| `just schema` | Show machine options schema | (inline) |

### Create

| Command | Purpose | Script |
|---------|---------|--------|
| `just new-module <path>` | Scaffold new module | Scaffold/default.nu |
| `just new-feature <module> <name>` | Add feature to module | Scaffold/feature.nu |

### Build

| Command | Purpose |
|---------|---------|
| `just check` | Validate flake |
| `just build <machine>` | Build machine image |
| `just vm <machine>` | Run machine in QEMU |

### Deploy

| Command | Purpose | Script |
|---------|---------|--------|
| `just flash <machine> <disk>` | Flash ISO to USB | Deploy/default.nu |
| `just format-persist <disk>` | Format SD for persistence | Deploy/format-persist.nu |
| `just remote-build <host> <machine>` | Build on remote, retrieve ISO | Deploy/remote-build.nu |
| `just ssh <machine>` | SSH into deployed machine | (inline) |

## Flake Targets

| Target | Scope | Purpose |
|--------|-------|---------|
| `flake.modules.homeManager.*` | User | Home-manager modules |
| `flake.modules.nixos.*` | System | NixOS modules |
| `flake.modules.darwin.*` | System | nix-darwin modules |
| `perSystem.devShells.*` | Dev | Development environments |
| `perSystem.packages.*` | Build | Derivations |
| `perSystem.checks.*` | CI | Validation |

## Bindings Categories

| Category | Signature | Purpose |
|----------|-----------|---------|
| Scripts | `() -> Effect` | Entry points (default.nu) |
| Commands | `Cmd -> Effect` | CLI commands |
| Keymaps | `Key -> Action` | Input bindings |
| Hooks | `Event -> Effect` | Lifecycle (Init, Save, Load, Log, Sync, Cleanup) |
| State | `S -> S` | State machines |
| Secrets | `Path -> Value` | Sensitive data |
| Plugins | `Base -> Extended` | Extensions |

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| Nix float literals like `3e-4` fail | Use `lib.types.str` with `"3e-4"`, parse in binding |
| Module not exported | Ensure `enable = true` in Bindings |
| Infinite recursion | Don't set `x.enable` inside `mkIf x.enable` |
| New dirs not found | `git add` before rebuild (import-tree) |
| Type mismatches | Use `just options <module>` to see exact type space |

## Configuration Surface Isomorphism

All configuration mechanisms are equivalent:

```
CLI flags    =  ENV vars      =  Config files    =  Options/default.nix
--port=8080  =  PORT=8080     =  port: 8080      =  port = 8080;
--verbose    =  VERBOSE=true  =  verbose: true   =  verbose = true;
```

Pick whichever the tool supports best, wire in Bindings.
