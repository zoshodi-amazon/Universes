# AGENTS.md

Agent-optimized context for the Universes Prelude repository.

Pattern Version: v2.0.0 | Structure: FROZEN

## Philosophy

- Index on CAPABILITY, not IMPLEMENTATION
- Minimize the generating set: prefer tools spanning multiple capabilities
- New dependency rule: add a tool IF AND ONLY IF no existing tool covers the capability
- TUI = justfile + gum (no additional frameworks)

## Type-Theoretic Identity

- Artifact = typed option module (bounded params, no nulls, <= 7 params)
- Monad = artifact-producing type constructor
- `[IO?]M{Interpreter}{ArtifactType}` = named monad
- ENV var = runtime projection of an Artifact param (1-1 mapping)
- CLI command = named fold over the Artifact type space
- Justfile recipe = kebab-case mirror of Monad name
- Artifacts are compact metric spaces with bounded defaults as fixed points
- NO nulls, NO empty strings, NO `Option.none` as default — use explicit sum types
- NO loose strings as types — physical quantities use typed structures (value + unit)
- NO string interpolation — destroys type structure
- 7 dimensions max per Artifact (cognitive bound)
- Errors/exceptions typed explicitly as sum types, never null, never untyped strings

## Naming Convention (FROZEN)

- `Artifacts/{Interpreter}{ArtifactType}/default.{ext}` — typed option module
- `Monads/[IO?]M{Interpreter}{ArtifactType}/` — artifact-producing script/derivation
- `just [io-]{interpreter}-{artifacttype}` — CLI recipe (kebab-case mirror)
- IO prefix = effectful, no prefix = pure
- From name alone derive: interpreter, mutability, phase, type

```
Directory                              CLI / Justfile recipe
Monads/MLeanSovereignty/               just lean-sovereignty
Monads/IOMLeanSovereignty/             just io-lean-sovereignty
Monads/IOMLeanMain/                    just io-lean-main
Monads/IOMLeanPackage/                 just io-lean-package
```

## Execution Stack

```
Nix (types + packaging) → Lean (glue + folds) → CLIs (effects)
```

- Nix Artifacts = single source of truth for ALL typing
- Lean ADT = canonical type definition with complete closure
- Lean Monads = typed folds/eliminators over the ADT
- Lean compiles to native binary via lean4-nix (lake2nix)
- Justfile aggregates all Monads as man-page-style recipes
- Arch.d2 = morphism diagram: trace any capability from type to term to effect

```
ADT (Lean) → Artifacts/default.nix (Nix) → ENV vars (JSON) → Monads (Lean folds) → IO effects
```

## Module Structure

```
<Module>/
├── Artifacts/                              # Typed option modules (metric spaces, <= 7 params)
│   ├── {Interpreter}{ArtifactType}/        # Each artifact is a bounded metric space
│   │   └── default.{ext}                   # Canonical type definition
│   └── default.nix                         # Nix projection of all artifacts
├── Monads/                                 # Artifact-producing scripts/derivations
│   ├── M{Interpreter}{ArtifactType}/       # Pure monad
│   ├── IOM{Interpreter}{ArtifactType}/     # Effectful monad
│   └── default.nix                         # Import-tree entry
├── default.nix                             # Global instantiation
└── README.md
```

## Invariants

1. Every `.nix` file is a flake-parts module
2. Every Module has: README.md, default.nix, Artifacts/, Monads/
3. File naming: `default.*` only. Directory-level naming for non-Nix types. Project-specific naming ONLY in Monads/ where build tools require it.
4. NO manual imports (import-tree auto-imports)
5. NO vendor names in Artifacts (handle in Monads)
6. NO nulls — all params bounded with defaults
7. NO loose strings as types — use typed quantities, enums, sum types
8. Modules enable themselves: if created, capability is desired
9. Every Artifact has a 1-1 Monad. Missing Monad = a hole.
10. Justfile recipes match Monads 1-1 in kebab-case: `[io-]{interpreter}-{artifacttype}`
11. Lean is the glue language for new modules
12. Every command is an artifact-producing Monad
13. 7 params max per Artifact — decompose if exceeded
14. Justfile is man-page style: recipe name, params with descriptions, no fluff
15. Every Monad recipe SHOULD have a `{recipe}-options` pure introspection recipe printing the typed param space

## Categorical Organization

```
Modules/
├── Labs/     # perSystem — build-time artifacts, devShells, experiments
├── User/     # homeManager — user-space, platform-agnostic
├── Host/     # nixos/darwin — OS-level, system configuration
└── Fleet/    # *Configurations — top-level instantiators
```

Decision tree:
- Exports `flake.*Configurations`? → Fleet/
- Exports `flake.modules.{nixos,darwin}.*`? → Host/
- Exports `flake.modules.homeManager.*` ONLY? → User/
- Exports `perSystem.*` ONLY? → Labs/

## Anti-Patterns

- Vendor names in Artifacts → handle in Monads
- `null`, `""`, `Option.none` as default → explicit sum type with bounded default
- `String` for physical quantity → typed structure (value + unit)
- `String` for identifier → enum or inductive type
- `$"Found {count} items"` → structured output, typed pipelines
- Artifact with >7 params → decompose into sub-artifacts
- Imperative CLI names (`sov status`) → typed names (`just lean-sovereignty`)
- Hidden CLI params in scripts → all config explicit in Artifacts

## Toolchain

| Tool | Role |
|------|------|
| Nix Artifacts | Declare capability space, single source of truth |
| Lean 4 | Canonical types, exhaustive folds, compile to native CLI |
| lean4-nix | Build Lean projects in Nix (lake2nix) |
| justfile | Aggregation of all Monads, man-page style |
| gum | Styled terminal output |

## Flake Targets

| Target | Scope |
|--------|-------|
| `flake.modules.homeManager.*` | User |
| `flake.modules.nixos.*` | System |
| `flake.modules.darwin.*` | System |
| `perSystem.devShells.*` | Dev |
| `perSystem.packages.*` | Build |
| `perSystem.checks.*` | CI |
