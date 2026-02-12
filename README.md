# UNIVERSES(7) - Dendritic Nix Configuration System

## NAME

Universes - Capability-centric Nix configuration system using flake-parts + import-tree

## SYNOPSIS

```
<Module>/
├── Artifacts/       # Typed option modules (the type space)
├── Monads/          # Artifact-producing scripts/derivations
├── default.nix      # Global instantiation
└── README.md
```

**Pattern Version: v2.0.0**

## DESCRIPTION

Every module is a closed type space. Artifacts define what exists (types, bounded params). Monads produce artifacts (scripts, derivations, CLIs). The `default.nix` instantiates the module into the flake.

**One Universe = one git repo.** The ambient space. Modules live within it.

### Type-Theoretic Identity

```
Artifact         =  Typed option module (bounded params, no nulls)
Monad            =  Artifact-producing type constructor
[IO?]M{Type}     =  Named monad (IO = effectful, no prefix = pure)
ENV var          =  Runtime projection of an Artifact param
CLI command      =  Named fold over the Artifact type space
Justfile recipe  =  Aggregation of all Monads in one place
```

### Naming Convention

**FROZEN.** The directory name encodes interpreter, mutability, phase, and type. You can derive everything from the name alone.

```
Artifacts/   → {Interpreter}{ArtifactType}           — typed option modules
Monads/      → [IO?]M{Interpreter}{ArtifactType}     — artifact-producing scripts/derivations

{Interpreter}  = codec/language (Lean, Nix, Python, Rust, etc.)
{ArtifactType} = what the type space represents (Sovereignty, Item, Energy, etc.)
IO prefix      = effectful (writes, deploys, interactive, modifies state)
no prefix      = pure (queries, observations, read-only)
M prefix       = Monad (type constructor that produces the artifact)
```

From the name alone you derive:
- **Interpreter**: what codec/language (`Lean`, `Nix`, `Python`, ...)
- **Mutability**: `IO` prefix = effectful, no prefix = pure
- **Phase**: `M` prefix = type constructor (Monad)
- **Type**: the artifact type being produced or defined

Examples:
```
Artifacts/LeanSovereignty/default.lean    — Lean codec, Sovereignty type
Artifacts/LeanItem/default.lean           — Lean codec, Item type
Artifacts/NixPackage/default.nix          — Nix codec, Package type
Artifacts/LeanLake/lakefile.lean          — Lean codec, Lake project config
Monads/MLeanSovereignty/default.lean      — pure, Lean, produces Sovereignty queries
Monads/IOMLeanMain/Main.lean              — effectful, Lean, produces CLI entry point
Monads/IOMLeanSovereignty/default.lean    — effectful, Lean, produces Sovereignty mutations
```

### 1-1 Invariant

For every `Artifacts/{Interpreter}{Type}`, there must exist `Monads/[IO?]M{Interpreter}{Type}`. Missing Monad = a hole. Mechanically verifiable:

```
Artifacts/LeanSovereignty/  → Monads/MLeanSovereignty/ + Monads/IOMLeanSovereignty/   [OK]
Artifacts/LeanItem/         → (consumed by MLeanSovereignty, not standalone)            [OK]
Artifacts/NixPackage/       → (instantiated by default.nix)                             [OK]
```

### Module Structure

```
<Module>/
├── Artifacts/                              # Typed option modules (metric spaces, <= 7 params each)
│   ├── {Interpreter}{ArtifactType}/        # Each artifact is a bounded metric space
│   │   └── default.{ext}                   # Canonical type definition
│   └── default.nix                         # Nix projection of all artifacts
├── Monads/                                 # Artifact-producing scripts/derivations
│   ├── M{Interpreter}{ArtifactType}/       # Pure monad (queries, observations)
│   ├── IOM{Interpreter}{ArtifactType}/     # Effectful monad (builds, deploys, interactive)
│   └── default.nix                         # Import-tree entry
├── default.nix                             # Global instantiation (wires into flake)
└── README.md
```

### The Morphism Chain

```
ADT (Lean)  →  Artifacts/default.nix (Nix)  →  ENV vars (JSON)  →  Monads (Lean folds)  →  IO effects
   types           type space                    serialized config     eliminators              state
```

## OPTIONS

Artifacts must remain vendor-agnostic ("what I want"). Monads are vendor-specific ("how to get it").

**Anti-pattern** (coupled):
```nix
options.store.mlflow.trackingUri = ...;  # Vendor in Artifacts
```

**Correct pattern** (decoupled):
```nix
options.store.trackingUri = ...;         # Generic capability
options.store.backend = enum [ "mlflow" "wandb" "local" ];
```

**NO nulls.** Every param bounded with defaults. Errors typed as sum types.

**NO loose strings as types.** Physical quantities use typed structures (value + unit). Identifiers use enums. Sources use sum types.

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

## FILES

### Execution Stack

```
Nix (types + packaging) → Lean (glue + folds) → CLIs (effects)
```

| Layer | Role | Artifact |
|-------|------|----------|
| Nix Artifacts | Type declarations, single source of truth | `Artifacts/default.nix` |
| Lean ADT | Canonical type definition, complete closure | `Artifacts/{Type}/default.lean` |
| Lean Monads | Typed folds over Artifacts | `Monads/[IO?]M{Type}/` |
| CLIs | Effectful programs | `sov status`, `rl train`, etc. |

### Toolchain

| Tool | Layer | Role |
|------|-------|------|
| Nix Artifacts | Types | Declare capability space, single source of truth |
| Lean 4 | ADT + Glue | Canonical types, exhaustive folds, compile to native CLI |
| lean4-nix | Packaging | Build Lean projects in Nix (lake2nix) |
| justfile | Interface | Aggregation of all Monads — the user-facing API |
| gum | Formatting | Styled terminal output |

## ENVIRONMENT

Flake targets:

| Target | Scope | Purpose |
|--------|-------|---------|
| `flake.modules.homeManager.*` | User | Home-manager modules |
| `flake.modules.nixos.*` | System | NixOS modules |
| `flake.modules.darwin.*` | System | nix-darwin modules |
| `perSystem.devShells.*` | Dev | Development environments |
| `perSystem.packages.*` | Build | Derivations |
| `perSystem.checks.*` | CI | Validation |

## EXAMPLES

Every command is an artifact-producing Monad:

```
just sov-status          # MSovereignty: pure query over capability space
just sov-validate        # IOMSovereignty: effectful constraint check
just sov-pack nomadic    # IOMSovereignty: effectful mode filter
```

The justfile is the aggregation of all Monads across all modules. Each recipe maps 1-1 to a Monad.

Configuration surface isomorphism:
```
CLI flags  ≅  ENV vars  ≅  Config files  ≅  Artifacts/default.nix
```

## DIAGNOSTICS

### Category Decision Tree (Module Scope)

```
Look at default.nix:

Exports flake.*Configurations?            → Fleet/
Exports flake.modules.{nixos,darwin}.*?   → Host/
Exports flake.modules.homeManager.* ONLY? → User/
Exports perSystem.* ONLY?                 → Labs/
```

### 1-1 Invariant Check

```
For every Artifacts/X:
  Does Monads/[IO?]MX exist?
    YES → OK
    NO  → HOLE (missing monad for artifact)
```

## CAVEATS

1. Every `.nix` file is a flake-parts module
2. Every Module has: README.md, default.nix, Artifacts/, Monads/
3. File naming: `default.*` only. Directory-level naming for non-Nix types. Project-specific naming ONLY in Monads/ where build tools require it.
4. NO manual imports (import-tree auto-imports)
5. NO vendor names in Artifacts (handle in Monads)
6. NO nulls — all params bounded with defaults
7. NO loose strings as types — use typed quantities, enums, sum types
8. Modules enable themselves: if created, capability is desired
9. Every Artifact has a 1-1 Monad. Missing Monad = a hole.
10. Justfile is aggregation of all Monads — recipes match 1-1 with Monads
11. Lean is the glue language for new modules
12. Every command is an artifact-producing Monad: `[IO?]M{ArtifactType}`

## USAGE

```bash
nix flake check                           # Check invariants
home-manager switch --flake .#darwin      # Switch config
nix develop .#sovereignty                 # Enter sovereignty shell
just sov-status                           # Query capability space
```

## HISTORY

| Version | Date | Changes |
|---------|------|---------|
| v2.0.0 | 2026-02-12 | Artifacts/Monads structure, Lean as glue, 1-1 invariant, typed naming |
| v1.0.5 | 2026-02-06 | Scope-based categories (Labs/User/Host/Fleet) |
| v1.0.4 | 2026-02-05 | Platform-agnostic containers |
| v1.0.3 | 2026-01-27 | README.md required, Nushell standard |
| v1.0.0 | 2026-01-27 | Frozen structure, two-level adjunction |
