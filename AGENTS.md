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

## Type-Theoretic Identity

The system has a precise type-theoretic interpretation. Every structural element maps to a formal concept:

### Options = Type Spaces

`Options/default.nix` declares a type space. Each option parameter is a dimension of that space. Default values are fixed point boundaries — they define the center of the space. The option parameters together define the full typed option space. ENV vars map 1-1 to option parameters.

```
Options/default.nix  ≅  Type Space
option parameter     ≅  dimension of the space
default value        ≅  fixed point (center/attractor)
ENV var              ≅  runtime projection of a dimension
```

**NO nulls.** Every parameter MUST have a bounded default. Errors and exceptions are typed explicitly as sum types (e.g. `Result`, `Either`), never null, never untyped strings. If a parameter can be absent, use an explicit sum type (`enum [ "none" "value1" "value2" ]`), not null.

**NO loose strings as types.** Strings are opaque — they bypass the type system entirely. Physical quantities MUST use typed structures with value + unit (e.g. `Mass { value : Float, unit : MassUnit }` not `weight : String`). Identifiers MUST use enums or inductive types. Sources MUST use sum types (e.g. `SourceType.url addr | SourceType.local vendor | SourceType.diy`). If you find yourself writing `field : String := ""`, you have an untyped hole — replace it with a proper bounded type.

```
WRONG:  weight : String := "0g"       -- opaque, no unit, no arithmetic
RIGHT:  weight : Mass := { value := 0.0, unit := .g }

WRONG:  source : String := ""         -- empty string = null in disguise
RIGHT:  source : SourceType := .diy   -- explicit sum type, bounded

WRONG:  status : Bool := false        -- bool is a 1-bit enum with no semantics
RIGHT:  status : AcqStatus := .needed -- typed lifecycle with clear states
```

**Artifacts are tightly bounded metric spaces.** Every parameter has a well-defined default (the fixed point / center of the space). There is no concept of null, empty string, or uninitialized — these are ill-defined fixpoints in a broken monoidal structure. If a value can be absent, model it as an explicit sum type (`enum [ "none" "value1" "value2" ]`), never as null or `""`. String interpolation is the canonical anti-pattern: it takes typed values and collapses them into an opaque, untyped string — destroying all structure. Every base case must be properly typed with clear bounded semantics.

**7 dimensions max per Artifact.** An Artifact's option space MUST NOT exceed 7 parameters. This is the cognitive bound — a human can hold roughly 7 dimensions simultaneously. If a type space exceeds 7 params, decompose it into sub-artifacts. Each sub-artifact is its own compact metric space with its own 1-1 Monad. The geometric shape of the metric space is real — 7 params = a 7-dimensional polytope with bounded defaults as the center. Justfile recipes match Monads exactly, so the user sees the same decomposition.

```
WRONG:  null, "", Option.none as default    — untyped absence, no fixed point
RIGHT:  explicit sum type with bounded default — typed absence, clear fixed point

WRONG:  $"Found {count} items in {dir}"     — typed values collapsed to opaque string
RIGHT:  structured output, typed pipelines   — structure preserved through the chain

WRONG:  Artifact with 15 params             — exceeds cognitive bound, undigestible
RIGHT:  3 sub-artifacts of 5 params each    — compact, each fully comprehensible
```

### Lean Instance Priorities

Lean's typeclass system supports instance priorities via `@[default_instance]` and numeric priority annotations. This maps directly to the globality ordering — more global constraints get higher priority and resolve first:

```lean
-- Higher priority = resolves first = more global
@[default_instance high] instance : HasSignature Energy where ...
@[default_instance mid]  instance : HasSignature Comms where ...
@[default_instance low]  instance : HasSignature Trade where ...
```

Instance priorities encode the same hierarchy as the p-adic globality ordering: Tier 1 domains (energy, water, food, shelter) get high priority, Tier 4 (transport, trade, fabrication) get low. When multiple instances could satisfy a typeclass constraint, the most global one wins. This is the type-level encoding of "what matters most."

Use `instance (priority := N)` for fine-grained control:

```lean
instance (priority := 1000) : Portable Item where ...    -- always check portability
instance (priority := 100)  : Auditable Item where ...   -- audit after portability
instance (priority := 10)   : Displayable Item where ... -- display is cosmetic
```

### Bindings = Type Constructors / Eliminators / Folds

`Bindings/` contains the eliminators (folds) over the type space. Each script/function is a type constructor that consumes the Options type and produces an effect. In Lean terms:

```
Binding  ≅  Eliminator : OptionSpace → IO Effect
Script   ≅  Monad : Type → Type (a type constructor)
CLI cmd  ≅  Named fold over the type space
```

Every fold over the type space = a CLI command. Every CLI command = a justfile recipe. The ADT of a module should enumerate ALL possible CLI commands — if you can write a fold over the type space, it should have a CLI.

### Module Self-Containment

Every module is a closed type space:

```
<Module>/
├── Options/default.nix     # Type space (all params bounded, no nulls)
├── Bindings/default.lean   # Eliminators/folds (compile to CLI binary)
├── Instances/default.nix   # Realizes CLI binary from type space
└── default.nix             # Import-tree entry
```

- Options/ declares the full param space with tight threshold boundaries on ALL params
- Bindings/ contains the Lean source that folds over the type space, producing CLI subcommands
- Instances/ wires the compiled CLI binary into the flake, matching CLI params to the option space
- Drv/ handles global dependency pinning (shriek/pullback of external repos — Python, Rust, C libs)
- Env/ aggregates Options into ENV vars AND produces default.json (serialized config for CLI binaries)
- Internal + external capability is closed within the typed option module
- Justfile wraps all module CLIs, grouped by phase (semantic script grouping)

### The Morphism Chain

```
ADT (Lean)  →  Options (Nix)  →  ENV vars  →  CLI binary (Lean folds)  →  IO effects
   types         projection       runtime        eliminators               state
```

### Lean as Glue Language

Lean replaces Nushell as the glue/scripting layer for new modules. Lean provides:

- Dependent types with compile-time exhaustiveness checking
- Native IO monad — honest about effects
- Pattern matching that the compiler enforces as total
- No null — `Option` type for absence
- Compiles to native binary — fast, no interpreter needed
- Interops with external CLIs via `IO.Process.spawn`

For interop with Python/Rust/C libs: pin deps in Drv/, create a CLI wrapper within the module, call via `IO.Process.spawn` from Lean. The CLI boundary is the universal interface.

```lean
-- Bindings/default.lean — eliminators over the type space
def status (cfg : Sovereignty) : IO Unit := do
  let gaps := cfg.domains.filter (·.hasGaps)
  IO.println s!"Coverage: {cfg.coverage}% | Gaps: {gaps.length}"

def main (args : List String) : IO Unit := do
  let cfg ← loadConfig
  match args with
  | ["status"]      => status cfg
  | ["gaps"]        => gaps cfg
  | ["bom"]         => bom cfg
  | ["pack", mode]  => pack cfg (parseMode mode)
  | _               => usage
```

### Packaging Pattern (Lean via lean4-nix)

```nix
# Drv/sov/default.nix — compile Lean to native binary
{ lean4-nix, lake2nix, ... }:
lake2nix.mkPackage {
  name = "sov";
  src = ./src;
}

# Instances/default.nix — realize CLI in flake
config.perSystem = { pkgs, ... }: {
  packages.sov = pkgs.callPackage ../../Drv/sov {};
};
```

## Execution Stack

```
Nix (types + packaging) → Lean (glue + folds) → CLIs (effects)
```

| Layer | Role | Artifact |
|-------|------|----------|
| Nix Options | Type declarations, single source of truth | `Options/default.nix` |
| Lean ADT | Canonical type definition, complete closure | `Sovereignty.lean`, etc. |
| Nix Drv | Freeze language-specific logic into CLI | `Drv/<pkg>/default.nix` |
| Lean Scripts | Glue layer, typed folds over Options | `Bindings/default.lean` |
| CLIs | Effectful programs (Python, Rust, etc.) | `sov status`, `rl train`, etc. |

**Key principles:**
- Nix module Options = single source of truth for ALL typing
- Lean ADT = canonical type definition with complete closure
- Lean scripts are typed folds/eliminators over the ADT
- Language-specific logic frozen in Drv/ with CLI interface
- Lean orchestrates CLIs via IO.Process.spawn — never calls language APIs directly
- Arch.d2 = morphism diagram: trace any capability from type → term → effect
- Implementation is mechanical from a correct Arch.d2

**The morphism chain:**
```
ADT (Lean types) → Options (Nix projection) → ENV vars (config) → Lean folds (glue) → CLI (effects) → Data (state)
```

### Toolchain

Each layer in the stack has a minimal, purpose-fit tool:

| Tool | Layer | Role |
|------|-------|------|
| nh | Discovery | Fast nixpkgs search + Nix CLI wrapper (`nh search`, `nix run`) |
| Nix Options | Types | Declare capability space, single source of truth |
| Lean 4 | ADT + Glue | Canonical types, exhaustive folds, compile to native CLI |
| lean4-nix | Packaging | Build Lean projects in Nix (lake2nix) |
| uv | Packaging | Install Python deps into venv inside Nix derivation |
| makeWrapper | CLI | Wrap a Python/Rust/etc binary with correct PATH/PYTHONPATH |
| justfile | Interface | Self-documenting recipes — thin wrapper over module CLIs, the user-facing API |
| gum | Formatting | Styled terminal output (borders, colors, prompts) |

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
4. File naming: `default.*` only (default.nix, default.nu, default.lean). Non-Nix typed option spaces use directory-level naming: `Options/Sovereignty/default.lean`, NOT `Options/Sovereignty.lean`. Project-specific naming (Lake's `Main.lean`, `lakefile.lean`, etc.) is allowed ONLY inside `Drv/` where language-specific build tools require it.
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

Tool selection is a statistical best-fit problem. Discovery MUST be zero-commitment and instant.

### Discovery Invariant

**Try before you type.** No tool enters Options/Bindings/Drv until it has been run interactively via `nix run` and confirmed to work on the target platform. The discovery phase is pure exploration — zero module changes, zero packaging. Only after a tool is validated does it get frozen into the module structure.

```bash
# Phase 1: Search (zero commitment)
nh search <capability-keyword>

# Phase 2: Try (zero commitment)
nix run nixpkgs#<tool> -- --help
nix run nixpkgs#<tool> -- <sample-input>

# Phase 3: Verify platform support
nix eval "nixpkgs#<tool>.meta.platforms" --json

# Phase 4: Freeze (commitment — only after Phase 1-3 pass)
# Add to Options, wire in Bindings, add to Instances
```

Justfile recipes for rapid discovery:

```
just discover <domain>     # curated list of nixpkgs tools per capability domain
just try <pkg> [args...]   # nix run nixpkgs#<pkg> -- <args>
just platforms <pkg>       # check platform support (darwin, linux)
```

### Discovery Process
1. **Define** - Enumerate required capabilities with weights
2. **Search** - `nh search <keyword>` — find candidates in nixpkgs
3. **Try** - `nix run nixpkgs#<candidate>` — zero-commitment interactive test
4. **Verify** - `nix eval "nixpkgs#<candidate>.meta.platforms"` — confirm darwin/linux support
5. **Score** - Evaluate capability coverage per candidate
6. **Select** - Choose minimal set (no over/underfit)
7. **Freeze** - Document in Options, never revisit without cause

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

### Lean Calling Frozen CLI (CORRECT — preferred for new modules)

```lean
-- YES: CLI boundary — Python frozen in Drv/, Lean calls CLI only
def train (cfg : RLConfig) : IO Unit := do
  let proc ← IO.Process.spawn {
    cmd := "rl"
    args := #["train", "--env", cfg.envId, "--algo", cfg.algorithm]
  }
  let exitCode ← proc.wait
  if exitCode != 0 then throw (IO.userError "training failed")

-- YES: Lean pattern matching is exhaustive — compiler enforces total coverage
def dispatch (cmd : Command) : IO Unit :=
  match cmd with
  | .status => status
  | .gaps   => gaps
  | .bom    => bom
  -- adding a new Command constructor without a case here = compile error
```

### String as Type (WRONG)

```nix
# NO: string for physical quantity — opaque, no arithmetic, no unit safety
options.weight = lib.mkOption { type = lib.types.str; default = "0g"; };
options.source = lib.mkOption { type = lib.types.str; default = ""; };
```

```lean
-- NO: string for structured data — bypasses type system
structure Item where
  weight : String := "0g"
  source : String := ""
```

### Typed Quantities and Sum Types (CORRECT)

```nix
# YES: structured type with value + unit (parsed in Nix as submodule)
options.weight = lib.mkOption {
  type = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "g" "kg" ]; default = "g"; };
  };
};
# YES: enum for source type
options.source = lib.mkOption {
  type = lib.types.enum [ "diy" "salvage" "trade" "url" "local" ];
  default = "diy";
};
```

```lean
-- YES: typed quantity — compiler enforces unit consistency
structure Mass where
  value : Float := 0.0
  unit  : MassUnit := .g

-- YES: sum type for source — exhaustive, no empty string
inductive SourceType where
  | url (addr : String) | local (vendor : String) | diy | salvage | trade
```

### Null or Untyped Errors (WRONG)

```nix
# NO: null as default — untyped absence
options.foo.bar = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
```

```lean
-- NO: string errors — untyped, no exhaustive handling
throw (IO.userError "something went wrong")
```

### Bounded Defaults and Typed Errors (CORRECT)

```nix
# YES: explicit sum type for absence, bounded default
options.foo.bar = lib.mkOption {
  type = lib.types.enum [ "none" "value1" "value2" ];
  default = "none";
};
```

```lean
-- YES: typed error ADT — exhaustive, compiler-checked
inductive SovError where
  | missingItem (domain : DomainId) (cap : CapId)
  | overWeight (actual : Float) (limit : Float)
  | untrainedCap (cap : CapId)

def validate (cfg : Sovereignty) : Except SovError Unit := do
  -- compiler enforces all SovError cases are handled by callers
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
├── Env/                # Options -> ENV vars + default.json (serialized config)
├── Instances/          # Env -> flake targets
└── Universe/
    └── <Feature>/
        ├── Options/    # Type space (capability schema)
        └── Bindings/   # Eliminators/folds (compile to CLI binary)
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
