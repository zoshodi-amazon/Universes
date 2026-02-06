# AGENTS.md

Agent-optimized context for the Universes Prelude repository.

Pattern Version: v1.0.5 | Structure: FROZEN

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

**Symmetry basis: Maximum deployment scope.**

Every module is classified by the highest level of the system hierarchy it can coherently target. This is mechanically checkable by inspecting `Instances/default.nix`.

```
Modules/
├── Labs/     # perSystem — build-time artifacts, devShells, experiments
├── User/     # homeManager — user-space, platform-agnostic
├── Host/     # nixos/darwin — OS-level, system configuration
└── Fleet/    # *Configurations — top-level instantiators
```

### Scope Hierarchy

```
perSystem (build-time only, no deployment state)
  ⊂ homeManager (user-space, any platform)
    ⊂ nixos/darwin (system-level, specific OS)
      ⊂ *Configurations (full instantiation = system + users + hardware)
```

### Category Decision Tree

```
Look at Instances/default.nix:

Exports flake.*Configurations?            → Fleet/
Exports flake.modules.{nixos,darwin}.*?   → Host/
Exports flake.modules.homeManager.* ONLY? → User/
Exports perSystem.* ONLY?                 → Labs/
```

### Category Boundaries

| Category | Scope | Essence | Target |
|----------|-------|---------|--------|
| **Labs** | perSystem | Build-time workspaces, experiments, tooling | devShells, packages, checks |
| **User** | homeManager | User environment, preferences, tools | flake.modules.homeManager.* |
| **Host** | nixos/darwin | System-level daemons, OS config, containers | flake.modules.{nixos,darwin}.* |
| **Fleet** | *Configurations | Instantiators that yield deployable artifacts | flake.{home,nixos}Configurations |

### Quick Reference

| Thing | Category | Why |
|-------|----------|-----|
| Audio workstation, RL training | Labs | perSystem devShells/packages |
| Checks, deploy scripts | Labs | perSystem checks/packages |
| Neovim, shells, browsers | User | homeManager user preferences |
| Git config, SSH | User | homeManager user-space |
| Nix daemon, secrets | Host | Requires nixos/darwin system access |
| Servers (podman containers) | Host | Requires nixos systemd |
| Home (homeConfigurations) | Fleet | Instantiates top-level output |
| Machines (nixosConfigurations) | Fleet | Instantiates top-level output |

### Hierarchy

| Level | Location | Has | Example |
|-------|----------|-----|---------|
| Category | `Modules/<Cat>/` | `default.nix` only | `Labs/`, `User/` |
| Module | `Modules/<Cat>/<Mod>/` | README.md, Arch.d2, Env/, Instances/, Universe/ | `Browsers/`, `Terminal/Shell/` |
| Feature | `Universe/<Feat>/` | Options/, Bindings/ | `Universe/Firefox/`, `Universe/Config/` |

Categories are organizational containers. Modules are capability units with full structure. Features are local sub-modules within a Module's Universe/.

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
18. Every module requires README.md + Arch.d2 (architecture diagram)
19. Naming is semantic binding to capability - optimize for best fit
20. CLI output uses gum styling, external tools run silent (-q, -loglevel error)
21. Justfile is self-documenting: recipes match 1-1 with README capabilities

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
just features Modules/User/Terminal       # List features in module
just options Modules/User/Terminal        # Show capability space
```

### 2. Create

```bash
just new-module Modules/User/Foo           # Scaffold new module
just new-feature Modules/User/Foo Bar      # Add feature to module
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

Thin interface to scripts in `Modules/Labs/Scripts/Universe/*/Bindings/Scripts/`.

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
