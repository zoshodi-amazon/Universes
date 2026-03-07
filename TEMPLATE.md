# TEMPLATE.md

Canonical naming and structural template for the Universes repository. Every name is a type. Every path is a type annotation. No ad-hoc naming. No exceptions.

Pattern Version: v5.2.0 | Type: CoIO (observation of naming invariants)

---

## 1. Universe Root

The repo root IS the type universe. Two top-level directories partition existence into dual halves:

```
{Universe}/
  Types/          -- Algebra   (production, catamorphic, free functor)
  CoTypes/        -- Coalgebra (observation, anamorphic, forgetful functor)
```

**Naming rule:** `Types/` and `CoTypes/` are the ONLY top-level source directories. Everything else at root is a classified root-level file (see Section 9).

---

## 2. The 7 Categories (FROZEN)

Every directory inside `Types/` or `CoTypes/` belongs to exactly one of 7 type-theoretic categories. The name IS the category. The category IS the type.

### Types/ (Algebraic)

| # | Directory Name | Type Theory | Matter Phase | Role |
|---|----------------|-------------|--------------|------|
| 1 | `Identity` | Unit (top) | BEC | Terminal objects: one canonical inhabitant |
| 2 | `Inductive` | ADT / Sum | Crystalline | Constructors: finite enumerated variants |
| 3 | `Dependent` | Indexed / Fibered | Liquid Crystal | Parameterized structures: fibered over Inductive |
| 4 | `Hom` | Function (A -> B) | Liquid | Morphisms: phase input specifications |
| 5 | `Product` | Product (A x B) | Gas | Outputs: phase results (Output + Meta) |
| 6 | `Monad` | Monad (M A) | Plasma | Effects: errors, build/switch results |
| 7 | `IO` | IO | QGP | Executors: effectful profunctor arrows (Nix + Lake) |

### CoTypes/ (Coalgebraic -- 1-1 dual)

| # | Directory Name | Type Theory | Dual Of | Role |
|---|----------------|-------------|---------|------|
| 1 | `CoIdentity` | Coterminal | Identity | Introspection witnesses: installed? present? |
| 2 | `CoInductive` | Cofree | Inductive | Elimination forms: parsers, validators |
| 3 | `CoDependent` | Cofibration | Dependent | Lifting: schema conformance validators |
| 4 | `CoHom` | Destructors | Hom | Observation specs (field-parallel, Bool/Option) |
| 5 | `CoProduct` | Coproduct | Product | Observation results: what was seen |
| 6 | `Comonad` | Comonad | Monad | Traces: extract (current) + extend (history) |
| 7 | `CoIO` | Observer | IO | Observer executors: probes, not producers |

**Naming rule:** Category names are PascalCase. CoTypes categories are prefixed with `Co` (not `co`). The sole exception is `Comonad` (standard mathematical spelling, not `CoMonad`).

---

## 3. The 7-Phase Chain (Domain Layer)

Phases are domain-specific applications of the 7 categories to device configuration. The phase name is domain-semantic; the type-theoretic identity is the invariant.

```
Identity -> Platform -> Network -> Services -> User -> Workspace -> Deploy
(Unit)      (ADT)       (Indexed)  (A -> B)    (AxB)   (M A)        (IO)
```

### Phase Names (FROZEN)

| # | Phase | Category | What It Configures |
|---|-------|----------|--------------------|
| 1 | `Identity` | Unit | Secrets, keys, Nix daemon, user account |
| 2 | `Platform` | Inductive | Boot, disk, hardware, display, peripherals |
| 3 | `Network` | Dependent | Firewall, SSH, wireless, VPN, DNS |
| 4 | `Services` | Hom | Containers, daemons, databases |
| 5 | `User` | Product | Shell, terminal, editor, browser, CLI tools |
| 6 | `Workspace` | Monad | DevShells, language toolchains, build systems |
| 7 | `Deploy` | IO | homeConfigurations, nixosConfigurations, ISOs, VMs |

### User Sub-Phases (7, same category chain)

| # | Sub-Phase | What It Configures |
|---|-----------|-------------------|
| 1 | `Identity` | User account, home directory |
| 2 | `Credentials` | Git identity, SSH keys, tokens |
| 3 | `Shell` | Zsh, fish, nushell, direnv |
| 4 | `Terminal` | Tmux, kitty |
| 5 | `Editor` | Neovim (nixvim) |
| 6 | `Comms` | Browser, AI, cloud CLI, mail |
| 7 | `Packages` | Standalone packages list |

**Naming rule:** Phase names are PascalCase. Sub-phase names are PascalCase. Never lowercase, never kebab-case, never snake_case in directory names.

---

## 4. Directory Path Templates

Directory paths ARE type annotations. The path encodes: which half (Types/CoTypes), which category, which phase, and which role.

### Types/ Paths

```
Types/Identity/                          -- Category 1: terminal objects
Types/Inductive/                         -- Category 2: ADT variants
Types/Dependent/                         -- Category 3: indexed structures
Types/Hom/{Phase}/                       -- Category 4: phase input morphisms
Types/Hom/User/{SubPhase}/               -- Category 4: user sub-phase morphisms
Types/Product/{Phase}/Output/            -- Category 5: phase output
Types/Product/{Phase}/Meta/              -- Category 5: phase metadata
Types/Product/User/{SubPhase}/Output/    -- Category 5: user sub-phase output
Types/Product/User/{SubPhase}/Meta/      -- Category 5: user sub-phase meta
Types/Monad/                             -- Category 6: effect types
Types/IO/                                -- Category 7: Lake project root
Types/IO/IO{Phase}Phase/                 -- Category 7: phase IO executor
Types/IO/IOUserPhase/Monads/IO{SubPhase}Phase/  -- Category 7: user sub-phase executor
```

### CoTypes/ Paths

```
CoTypes/CoIdentity/                      -- CoCategory 1: introspection witnesses
CoTypes/CoInductive/                     -- CoCategory 2: elimination forms
CoTypes/CoDependent/                     -- CoCategory 3: cofibration validators
CoTypes/CoHom/                           -- CoCategory 4: observation specifications
CoTypes/CoProduct/                       -- CoCategory 5: observation results
CoTypes/Comonad/                         -- CoCategory 6: observation traces
CoTypes/CoIO/                            -- CoCategory 7: observer result types
CoTypes/CoIO/CoIO{Phase}Phase/           -- CoCategory 7: phase observer executor (planned)
```

### IO Executor Naming

IO executor directories follow the pattern `IO{Phase}Phase`:

| Phase | IO Executor Dir | CoIO Observer Dir |
|-------|----------------|-------------------|
| Identity | `IOIdentityPhase` | `CoIOIdentityPhase` |
| Platform | `IOPlatformPhase` | `CoIOPlatformPhase` |
| Network | `IONetworkPhase` | `CoIONetworkPhase` |
| Services | `IOServicesPhase` | `CoIOServicesPhase` |
| User | `IOUserPhase` | `CoIOUserPhase` |
| Workspace | `IOWorkspacePhase` | `CoIOWorkspacePhase` |
| Main (Deploy) | `IOMainPhase` | `CoIODeployPhase` |

**Naming rule:** `IO` prefix, phase name in PascalCase, `Phase` suffix. Always. The `Co` variant prepends `Co` to the entire token: `CoIO{Phase}Phase`.

---

## 5. File Naming

### Lean Files

Every Lean type definition file is named `Default.lean`. No exceptions.

```
Types/{Category}/Default.lean
Types/Hom/{Phase}/Default.lean
Types/Product/{Phase}/{Output,Meta}/Default.lean
CoTypes/{CoCategory}/Default.lean
```

The Lake project root is `Types/IO/`. The entry point executable is `Types/IO/Default.lean`.

Lake build config: `Types/IO/lakefile.lean`
Lean version pin: `Types/IO/lean-toolchain`

### Nix Files

IO executor Nix files are named `default.nix`. JSON boundaries are named `default.json`.

```
Types/IO/IO{Phase}Phase/default.nix      -- IO executor (produces system state)
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom at IO boundary
CoTypes/CoIO/CoIO{Phase}Phase/default.nix -- CoIO observer (probes system state)
```

### Python Files (Sub-Universes)

Sub-universes (RL, Fab, Sovereignty) use Python. Entry points are `default.py`, init files are `__init__.py`.

```
{SubUniverse}/Types/{Category}/{TypeName}/default.py
{SubUniverse}/Types/IO/IO{Phase}Phase/default.py
{SubUniverse}/Types/IO/IO{Phase}Phase/default.json
{SubUniverse}/CoTypes/{CoCategory}/{ObserverName}/default.py
{SubUniverse}/CoTypes/IO/IO{Phase}Phase/default.py
```

### Filetype Classification (FROZEN)

| Extension | Type Category | Rationale |
|-----------|--------------|-----------|
| `.lean` | Determined by directory | Type definitions: source of truth |
| `.nix` | IO (always under `Types/IO/` or `CoTypes/CoIO/`) | Effect executors |
| `.json` | IO boundary (`Types/IO/`) | Serialized Hom types |
| `.py` | Determined by directory | Parallel type system (sub-universes) |
| `.md` | CoIO / Comonad | Observation: describes without modifying |
| `.toml` | Dependent | Build parameterization: indexed over project |
| `.lock` | Identity | Terminal object: one canonical inhabitant |
| `.d2` | CoIO | Architectural observation diagram |

---

## 6. Lean Module Paths

With `srcDir := "../.."` (repo root), Lean module paths mirror the filesystem exactly:

```
import Types.Inductive.Default          -- Types/Inductive/Default.lean
import Types.Dependent.Default          -- Types/Dependent/Default.lean
import Types.Hom.Identity.Default       -- Types/Hom/Identity/Default.lean
import CoTypes.CoDependent.Default      -- CoTypes/CoDependent/Default.lean
import CoTypes.CoProduct.Default        -- CoTypes/CoProduct/Default.lean
```

### Import DAG (strictly layered, no upward imports)

```
Types.Identity <- Types.Inductive <- Types.Dependent <- Types.Hom.{Phase} <- Types.Product.{Phase}
                                                                            ^
                                                                      Types.Monad
                                                                            ^
                                                                       Types.IO
```

CoTypes may import Types (crossing the algebra/coalgebra boundary downward):

```
CoTypes.CoInductive  <- Types.Inductive     (elimination needs constructors)
CoTypes.CoDependent  <- Types.Inductive     (lifting needs fiber index)
CoTypes.CoHom        <- CoTypes.CoDependent (observation specs reference cofibrations)
CoTypes.CoIO         <- CoTypes.CoProduct   (observer results reference observation outputs)
CoTypes.CoIO         <- CoTypes.Comonad     (observer results reference traces)
```

### lakefile.lean Library Registration

Every `lean_lib` follows the naming pattern:

```lean
-- Types: category + phase name concatenated
lean_lib <<Identity>> where roots := #[`Types.Identity.Default]
lean_lib <<HomIdentity>> where roots := #[`Types.Hom.Identity.Default]
lean_lib <<ProductIdentityOutput>> where roots := #[`Types.Product.Identity.Output.Default]
lean_lib <<ProductIdentityMeta>> where roots := #[`Types.Product.Identity.Meta.Default]

-- CoTypes: Co-prefixed category name
lean_lib <<CoIdentity>> where roots := #[`CoTypes.CoIdentity.Default]
lean_lib <<CoHom>> where roots := #[`CoTypes.CoHom.Default]
```

---

## 7. Lean Structure Naming

### Types/ Structures

| Category | Pattern | Example |
|----------|---------|---------|
| Identity | `{Thing}` | `Package`, `ProgramConfig`, `Phase` |
| Inductive | `{VariantName}` (bare inductive) | `inductive BootLoader`, `inductive ShellEditor` |
| Dependent | `{ConfigName}` | `NixSettings`, `BootConfig`, `NetworkConfig` |
| Hom | `{Phase}Hom` | `IdentityHom`, `PlatformHom`, `UserShellHom` |
| Product Output | `{Phase}Output` | `IdentityOutput`, `PlatformOutput` |
| Product Meta | `{Phase}Meta` | `IdentityMeta`, `PlatformMeta` |
| Monad | `{Effect}` | `PhaseError`, `BuildResult`, `SwitchResult` |

### CoTypes/ Structures

| CoCategory | Pattern | Example |
|------------|---------|---------|
| CoIdentity | `Co{Thing}` | `CoPackage`, `CoProgramConfig`, `CoPhase` |
| CoInductive | `Co{Validator}` | `CoInductiveWitness`, `CoInductiveExhaustiveness` |
| CoDependent | `Co{ConfigName}` | `CoNixSettings`, `CoBootConfig`, `CoNetworkConfig` |
| CoHom | `Co{Phase}Hom` | `CoIdentityHom`, `CoPlatformHom`, `CoUserHom` |
| CoProduct Output | `Co{Phase}Output` | `CoIdentityOutput`, `CoPlatformOutput` |
| CoProduct Meta | `CoObservationMeta` | (shared across phases) |
| CoProduct Pair | `Co{Phase}Product` | `CoIdentityProduct` (observed + observation) |
| Comonad | `Observation{Thing}` | `ObservationEvent`, `ObservationTrace`, `ObservationError` |
| CoIO | `Observation{Thing}` | `ObservationResult`, `ObservationStatus`, `ObservationSummary` |

### Field Naming Rules

- All fields are `camelCase`
- Boolean observation fields: `{thing}Observed`, `{thing}Valid`, `{thing}Present`, `{thing}Active`
- No bare `String` for finite variants: extract to `Types/Inductive/` as `inductive` ADT
- No `output` as a field name (reserved word in Lean 4.28+). Use `observed` for CoProduct pairs
- No `meta` as a standalone field name in structures containing other structures. Use `observation` for CoProduct pairs
- All structures derive `Repr, Lean.ToJson, Lean.FromJson`
- Maximum 7 fields per structure (blowup prevention)

---

## 8. Justfile Command Naming

Every justfile command is a classified morphism. Three prefixes, no exceptions:

### Prefix Classification

| Prefix | Recursion Scheme | Direction | Maps To |
|--------|-----------------|-----------|---------|
| `ana-` | Anamorphism (unfold) | System -> Evidence | CoTypes/ |
| `cata-` | Catamorphism (fold) | Types -> System | Types/ |
| `hylo-` | Hylomorphism (unfold+fold) | Composite | Types/ tensor CoTypes/ |

### 6-Functor Classification

| 6FF Functor | Prefix | Meaning | Example |
|-------------|--------|---------|---------|
| f* (pullback) | `ana-` | Pull back observable data | `ana-show`, `ana-eval`, `ana-{phase}` |
| f! (shriek pullback) | `ana-` | Validation that may fail | `ana-check`, `ana-types-validate` |
| Hom (internal) | `ana-` | List/enumerate structure | `ana-keys`, `ana-modules-home` |
| f* (pushforward) | `cata-` | Push typed data into system | `cata-switch`, `cata-sync-to` |
| f! (shriek push) | `cata-` | Production with side effects | `cata-build`, `cata-gc`, `cata-types-build` |
| tensor (otimes) | `hylo-` | Composite: observe then produce | `hylo-main`, `hylo-remote-build` |

### Command Naming Patterns

```
ana-{phase}              -- Observe a specific phase
ana-user-{subphase}      -- Observe a user sub-phase
ana-types-validate       -- Validate Lean type schemas
ana-{verb} {arg}         -- General observation (eval, show, keys, search, info, size)
cata-{verb} {arg}        -- General production (build, switch, flash, update, gc, optimize)
cata-types-build         -- Build Lean type system
cata-sync-to {host}      -- Push repo to remote
cata-ssh {machine}       -- Connect to deployed target
hylo-main {host}         -- validate then switch (the event loop)
hylo-remote-{verb} {h}   -- Remote composite (build, switch, vm, microvm, install)
hylo-dev {shell}         -- Enter dev shell
```

**Naming rule:** All lowercase, kebab-case. Phase names in commands are lowercase (not PascalCase). No unprefixed commands except `default`.

---

## 9. Root-Level File Classification

Every file at the repo root has a type-theoretic classification:

| File | Type Category | Rationale |
|------|--------------|-----------|
| `flake.nix` | Hom (A -> B) | Top-level morphism: maps inputs to flake outputs |
| `flake.lock` | Identity (top) | Terminal object: one canonical inhabitant per input set |
| `justfile` | IO / CoIO | Dispatcher: each recipe is a classified morphism |
| `AGENTS.md` | CoIO | Observation of the system (agent instructions) |
| `README.md` | CoIO | Observation of the system (human documentation) |
| `DICTIONARY.md` | CoIO | Observation of the system (formal glossary) |
| `TRACKER.md` | CoIO | Observation of implementation state (progress) |
| `TEMPLATE.md` | CoIO | Observation of naming invariants (this file) |
| `.gitignore` | Dependent | Parameterizes what the git IO executor observes |

---

## 10. Git Commit Message Template

Commit messages are classified morphisms. The format:

```
[{Scope} | {Category}] v{Major}.{Minor}.{Patch}: {description}
```

### Scope (WHAT changed)

The scope names the top-level directory or cross-cutting concern:

| Scope | When |
|-------|------|
| `Types` | Changes to Types/ only |
| `CoTypes` | Changes to CoTypes/ only |
| `Types \| CoTypes` | Changes spanning both |
| `IO` | Changes to Types/IO/ executors only |
| `CoIO` | Changes to CoTypes/CoIO/ observers only |
| `Hom` | Changes to Types/Hom/ only |
| `Product` | Changes to Types/Product/ only |
| `Docs` | Documentation-only changes (CoIO observation) |
| `{SubUniverse}` | Changes to a sub-universe (RL, Fab, Sovereignty) |

### Category (TYPE of change)

The category classifies the nature of the morphism:

| Category | Type Theory | When |
|----------|-------------|------|
| `Identity` | Terminal (new canonical form) | New lockfile, new pinned version |
| `Inductive` | ADT (new variant) | New enum, new sum type |
| `Dependent` | Indexed (parameterized) | New/changed indexed structure |
| `Hom` | Morphism (new arrow) | New phase input type |
| `Product` | Output (new result) | New phase output/meta |
| `Monad` | Effect (new side effect) | New error type, new result type |
| `IO` | Executor (new effect) | New/changed Nix executor |
| `CoIO` | Observer (new probe) | New/changed observer |
| `Refactor` | Isomorphism | Structure-preserving rename/move |
| `Fix` | Retraction | Bug fix (retracts incorrect morphism) |
| `Docs` | CoIO | Documentation update |

### Version Semantics

| Component | Increments When |
|-----------|----------------|
| Major | Phase chain changes, category added/removed, invariant changed |
| Minor | New types, new executors, new phases within existing structure |
| Patch | Fixes, docs, minor field additions |

### Examples

```
[Types | CoTypes] v5.2.0: srcDir repo root, full module paths, all 7 CoTypes compile (117/117 jobs)
[Types | CoTypes] v5.1.0: Types/ + CoTypes/ at repo root, observation pipeline, DICTIONARY + TRACKER
[IO | Hom] v4.1.0: IOMainPhase entry point, IOUserPhase 7 sub-phases, Lean types
[RL | Refactor] Checkpoint
[Docs | CoIO] Update AGENTS.md observation pipeline
[CoIO | IO] v5.3.0: CoIO Nix executor scripts for all 7 phases
```

---

## 11. Sub-Universe Template

Sub-universes (RL, Fab, Sovereignty) are separate type systems with their own 7-phase chains. They live under `Types/IO/IOWorkspacePhase/` and are consumed by the parent universe as Identity types.

### Sub-Universe Root Structure

```
{SubUniverse}/
  Types/
    Identity/           -- Terminal objects for this domain
    Inductive/          -- ADTs for this domain
    Dependent/          -- Indexed structures for this domain
    Hom/
      {Phase}/          -- Phase input morphisms (domain-specific phases)
    Product/
      {Phase}/
        Output/         -- Phase outputs
        Meta/           -- Phase metadata
    Monad/              -- Effect types for this domain
    IO/
      IO{Phase}Phase/   -- IO executors
        default.json    -- Serialized Hom at boundary
        default.py      -- Executor implementation
  CoTypes/
    CoIdentity/         -- Introspection witnesses
    CoInductive/        -- Elimination forms
    CoDependent/        -- Schema validators
    CoHom/              -- Observation specs
    CoProduct/          -- Observation results
    Comonad/            -- Observation traces
    CoIO/ or IO/        -- Observer executors
  AGENTS.md             -- Agent instructions for this sub-universe
  README.md             -- Documentation
  justfile              -- Classified morphism dispatcher
  pyproject.toml        -- Dependent type (build parameterization)
```

### Sub-Universe Phase Naming

Each sub-universe defines its own 7-phase chain with domain-specific names:

**RL (Reinforcement Learning):**
```
Ingest -> Discovery -> Feature -> Train -> Eval -> Serve -> Main
```

**Fab (Fabrication):**
```
Ingest -> Discovery -> Geometry -> Dynamics -> Synthesis -> Render -> Serve
```

Phase names in sub-universes follow the same PascalCase convention and map to IO executors as `IO{Phase}Phase`.

---

## 12. The Profunctor Pattern (per phase)

Every phase follows the same profunctor structure. This is the template for adding a new phase:

```
Types/Hom/{Phase}/Default.lean           -- Domain (input specification)
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom at IO boundary
Types/IO/IO{Phase}Phase/default.nix      -- Arrow (effectful executor)
Types/Product/{Phase}/Output/Default.lean -- Codomain output
Types/Product/{Phase}/Meta/Default.lean   -- Codomain metadata
```

Observation dual (1-1):

```
CoTypes/CoHom/   (contains Co{Phase}Hom)    -- What to check
CoTypes/CoIO/CoIO{Phase}Phase/default.nix   -- How to check (probe)
CoTypes/CoProduct/ (contains Co{Phase}Product) -- What was seen
```

### Adding a New Phase (Checklist)

1. Name the phase (PascalCase, type-theoretically motivated)
2. Create `Types/Hom/{Phase}/Default.lean` with `{Phase}Hom` structure
3. Create `Types/Product/{Phase}/Output/Default.lean` with `{Phase}Output`
4. Create `Types/Product/{Phase}/Meta/Default.lean` with `{Phase}Meta`
5. Create `Types/IO/IO{Phase}Phase/default.nix` (IO executor)
6. Create `Types/IO/IO{Phase}Phase/default.json` (serialized Hom)
7. Register `lean_lib` entries in `Types/IO/lakefile.lean`
8. Add observation structures to CoTypes/ (CoHom, CoProduct)
9. Add `ana-{phase}` and verify `cata-` commands in justfile
10. Update TRACKER.md

---

## 13. Domain-Specific Names: WHERE They Live

Domain-specific naming (vendor names, tool names, application-specific identifiers) is NOT scattered across the codebase. It is precisely placed:

| Domain Name Type | WHERE It Lives | Example |
|-----------------|----------------|---------|
| Hardware variants | `Types/Inductive/Default.lean` | `BootLoader`, `MachineArch` |
| Tool choices | `Types/Inductive/Default.lean` | `ShellEditor`, `KittyTheme`, `Colorscheme` |
| Provider names | `Types/Inductive/Default.lean` | `AIProvider`, `SearchEngine` |
| Config parameters | `Types/Dependent/Default.lean` | `NixSettings.maxJobs`, `SshConfig.forwardAgent` |
| Phase input values | `Types/Hom/{Phase}/Default.lean` | `IdentityHom.nixSettings` |
| Package names | `Types/IO/IO{Phase}Phase/default.nix` | `pkgs.neovim`, `pkgs.tmux` |
| Nix module paths | `Types/IO/IO{Phase}Phase/default.nix` | `programs.git.enable` |
| Deployment targets | `Types/Hom/Deploy/Default.lean` | `HomeTarget`, `MachineConfig` |
| Flake inputs | `flake.nix` | `nixpkgs`, `home-manager`, `nixvim` |

**Naming rule:** Vendor/tool names NEVER appear in Types/ category or phase names. They appear ONLY as:
1. Inductive constructors (e.g., `| systemdBoot | grub`)
2. Dependent structure fields (e.g., `gitDelta : Bool`)
3. IO executor implementation details (Nix attribute paths)

The type system is vendor-agnostic. The IO executors are vendor-specific.

---

## 14. Invariant Summary

1. Every name is a type. Directory placement IS typing.
2. 7 categories in Types/, 7 dual categories in CoTypes/. 1-1 correspondence.
3. Category names are PascalCase. Co-prefix for duals (except `Comonad`).
4. Phase names are PascalCase in directories, lowercase in justfile commands.
5. All Lean files are `Default.lean`. All Nix executors are `default.nix`. All JSON boundaries are `default.json`.
6. IO executors: `IO{Phase}Phase`. CoIO observers: `CoIO{Phase}Phase`.
7. Lean structures: `{Phase}Hom`, `{Phase}Output`, `{Phase}Meta`, `Co{Phase}Hom`, `Co{Phase}Output`, `Co{Phase}Product`.
8. Justfile commands: `ana-` (observe), `cata-` (produce), `hylo-` (composite). No unprefixed commands.
9. Git commits: `[{Scope} | {Category}] v{M}.{m}.{p}: {description}`.
10. Domain-specific names live in Inductive (variants), Dependent (fields), and IO (implementations). Never in category or phase names.
11. Maximum 7 fields per structure, 7 phases per module, 7 sub-phases per phase.
12. No `null`, no bare `String` for enums, no `options` blocks in Nix, no upward imports in the DAG.
13. Sub-universes replicate the full Types/CoTypes structure with their own 7-phase chain.
14. Names are first-class citizens. Every name carries type-theoretic weight. No ad-hoc naming. No exceptions.
