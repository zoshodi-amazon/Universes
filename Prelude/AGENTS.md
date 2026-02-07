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

## Execution Stack

```
Nix (types + packaging) → Nushell (glue + interop) → CLIs (effects)
```

| Layer | Role | Artifact |
|-------|------|----------|
| Nix Options | Type declarations, single source of truth | `Options/default.nix` |
| Nix Drv | Freeze language-specific logic into CLI | `Drv/<pkg>/default.nix` |
| Nushell Scripts | Glue layer, typed off Options, calls CLIs | `Bindings/Scripts/default.nu` |
| CLIs | Effectful programs (Python, Rust, etc.) | `rl train`, `audio-process`, etc. |

**Key principles:**
- Nix module Options = single source of truth for ALL typing
- Nushell scripts typed off Nix module Options (config shape = Options type)
- Language-specific logic frozen in Drv/ with CLI interface
- Nushell orchestrates CLIs — never calls language APIs directly
- Arch.d2 = morphism diagram: trace any capability from type → term → effect
- Implementation is mechanical from a correct Arch.d2

**The morphism chain:**
```
Options (types) → ENV vars (config) → Nushell (glue) → CLI (effects) → Data (state)
```

### Toolchain

Each layer in the stack has a minimal, purpose-fit tool:

| Tool | Layer | Role |
|------|-------|------|
| Nix Options | Types | Declare capability space, single source of truth |
| uv | Packaging | Install Python deps into venv inside Nix derivation — fast, reliable, no nixpkgs breakage |
| makeWrapper | CLI | Wrap a Python/Rust/etc binary with correct PATH/PYTHONPATH — produces a clean CLI entry point |
| Nushell | Glue | Typed pipeline scripting — orchestrate CLIs, parse config, structured data flow |
| justfile | Interface | Self-documenting recipes — thin wrapper over nushell scripts, the user-facing API |
| gum | Formatting | Styled terminal output (borders, colors, prompts) — no TUI framework needed |

**Python packaging pattern (Drv/):**
```nix
# Use uv to install deps, makeWrapper to produce CLI
buildPhase = ''
  uv venv $out/venv --python ${python}/bin/python
  uv pip install --python $out/venv/bin/python <deps>
'';
installPhase = ''
  makeWrapper $out/venv/bin/python $out/bin/<cli-name> \
    --add-flags "$out/lib/main.py"
'';
```

This avoids fighting nixpkgs' broken/missing Python packages (e.g. ale-py on aarch64-darwin). uv resolves and installs from PyPI directly inside the Nix sandbox. The result is a hermetic derivation with a clean CLI.

**Why not buildPythonApplication with nixpkgs deps?**
Transitive dependency hell. A single unsupported platform in a deep transitive dep (e.g. `gymnasium → ale-py → aarch64-darwin`) blocks the entire build. uv sidesteps this entirely — it installs wheels from PyPI, handles platform-specific resolution, and is fast.

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
22. Containers are portable: Servers/ exports to BOTH homeManager and nixos
23. nixosConfigurations is for hardware/system only, imports homeConfigurations for users
24. Deployment target = hardware; Capability = containers (platform-agnostic)
25. Nushell scripts typed off Nix module Options — config shape = Options type
26. Language-specific logic frozen in Drv/ with CLI interface — nushell calls CLIs only
27. Arch.d2 is the morphism diagram — implementation is mechanical from it
28. NO string interpolation in nushell — use typed variables, `print` with arguments, structured data. Prefer `[$a $b] | str join " "` over `$"($a) ($b)"`. Strong typing over string templating.

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

### Nushell Calling Language APIs (WRONG)

```nu
# NO: language-specific logic in glue layer
python -c "import sb3; model = sb3.PPO('MlpPolicy', 'CartPole-v1'); model.learn(100000)"
```

### Nushell Calling Frozen CLI (CORRECT)

```nu
# YES: CLI boundary — Python frozen in Drv/, nushell calls CLI only
^rl train --env CartPole-v1 --algo ppo --timesteps 100000
```

### String Interpolation in Nushell (WRONG)

```nu
# NO: string interpolation is untyped string templating
print $"  Data: ($file) (($rows) rows)"
print $"  Models: ($total) total, ($validated) validated"
let msg = $"Processing ($name) with ($count) items"
```

### Typed Composition in Nushell (CORRECT)

```nu
# YES: typed variables, explicit conversions, str join for assembly
let file: string = ".lab/data/sample.csv"
let rows: int = (open $file | length)
print ["  Data:" $file ($rows | into string) "rows"] | str join " "

# YES: structured data, not string templates
let status: record<total: int, validated: int, best: string> = {
  total: $total
  validated: $validated
  best: $best_str
}
print ["  Models:" ($status.total | into string) "total," ($status.validated | into string) "validated"] | str join " "
```

## Nushell Type Discipline

Nushell is the glue layer in the execution stack. All nushell code MUST follow these typing rules to maintain the morphism chain from Nix Options through to CLI effects.

### Principle: Strong Typing Over String Templating

Nushell has a structural type system with `record<>`, `list<>`, `table<>`, typed function signatures (`def foo []: input -> output`), and `match` for dispatch. Use it. String interpolation (`$"..."`) bypasses the type system entirely — it is untyped string templating that produces opaque strings from typed values. This is the exact opposite of what we want.

### The Rules

1. Every `let` binding MUST have an explicit type annotation
2. Every `def` parameter MUST have a type annotation
3. Every `def` MUST declare input/output types via `[]: input -> output`
4. Use `str join` for string assembly — never `$"..."`
5. Use `| into int`, `| into string` for explicit type conversions
6. Use `match` for dispatch over values — never if/else chains on strings
7. Use `record<>` and `list<>` compound types where structure is known
8. Data flows through typed pipelines — not through string formatting

### Type Signature Reference

```nu
# Variable declarations — always annotate
let x: int = 9
let name: string = "hello"
let items: list<string> = ["a" "b" "c"]
let cfg: record<name: string, count: int> = {name: "foo", count: 3}

# Function signatures — annotate params AND input/output
def process [path: string, n: int]: nothing -> list<string> {
  open $path | lines | first $n
}

# Multiple input/output type pairs
def transform []: [
  string -> list<string>
  list<string> -> table
] { }

# Closures — annotate parameters
do {|nums: list<int>| $nums | math sum } [1 2 3]
```

### String Assembly Pattern

```nu
# WRONG: string interpolation
print $"Found ($count) items in ($dir)"

# CORRECT: str join with typed values
let count: int = 42
let dir: string = "/tmp"
print ["Found" ($count | into string) "items in" $dir] | str join " "

# CORRECT: for multi-part output, build a list and join
let parts: list<string> = [
  "  total:" ($total | into string)
  "validated:" ($validated | into string)
  "best:" $best_str
]
$parts | str join " " | print
```

### Record Pattern for Status/Config

```nu
# Build typed records, print fields — not interpolated strings
let status: record = {
  env: ($env.RL_ENV_ID? | default "stocks-v0")
  algo: ($env.RL_AGENT_ALGORITHM? | default "ppo")
  provider: ($env.RL_DATA_PROVIDER? | default "csv")
}
print ["  Env:" $status.env] | str join " "
print ["  Agent:" $status.algo] | str join " "
```

### Match for Dispatch

```nu
# WRONG: if/else chain on strings
if $provider == "csv" { ... } else if $provider == "yahoo" { ... }

# CORRECT: match (exhaustive pattern matching)
match $provider {
  "csv" => { open $file }
  "yahoo" => { ^rl data download --provider yahoo }
  "alpaca" => { ^rl data download --provider alpaca }
  _ => { error make {msg: "unknown provider"} }
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
| `.gitignore` blocks Nix modules | Patterns like `logs/` match `Universe/Logs/` — add `!**/Universe/Logs/` exclusion |
| tmux "no space for new pane" | Rebalance layout (`select-layout tiled`) after each `split-window`, not just at the end |
| tmux "can't find pane: 0" | Check `pane-base-index` — user config may set it to 1. Detect at runtime: `tmux show-option -gv pane-base-index` |
| tmux pane targeting | Use named windows: `new-session -n main`, target as `session:main.N`. Never use numeric window index (depends on `base-index`) |
| tmux preset scripts | Create all panes first (split + rebalance loop), then send-keys after layout is stable. Pane indices shift during splits |
| Python ML packages (tf, mlflow, sb3) | Create custom derivation in `Drv/` using uv rather than fight nixpkgs versions |
| `print [...] \| str join` in nushell | Wrong order — use `[...] \| str join " " \| print`. Data flows left to right, print is terminal effect |

## Configuration Surface Isomorphism

All configuration mechanisms are equivalent:

```
CLI flags    =  ENV vars      =  Config files    =  Options/default.nix
--port=8080  =  PORT=8080     =  port: 8080      =  port = 8080;
--verbose    =  VERBOSE=true  =  verbose: true   =  verbose = true;
```

Pick whichever the tool supports best, wire in Bindings.
