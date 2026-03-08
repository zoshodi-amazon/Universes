# TEMPLATE.md

Canonical naming and structural template for the Universes monorepo. Every name is a type. Every path is a type annotation. No ad-hoc naming. No exceptions.

Lab-specific TEMPLATE.md files extend this document with language-specific naming and phase names.

---

## 1. Lab Root

Each lab root IS a type universe. Two top-level directories partition existence into dual halves:

```
{Lab}/
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
| 6 | `Monad` | Monad (M A) | Plasma | Effects: errors, build/validation results |
| 7 | `IO` | IO | QGP | Executors: effectful profunctor arrows |

### CoTypes/ (Coalgebraic -- 1-1 dual)

| # | Directory Name | Type Theory | Dual Of | Role |
|---|----------------|-------------|---------|------|
| 1 | `CoIdentity` | Coterminal | Identity | Introspection witnesses: present? valid? |
| 2 | `CoInductive` | Cofree | Inductive | Elimination forms: parsers, validators |
| 3 | `CoDependent` | Cofibration | Dependent | Lifting: schema conformance validators |
| 4 | `CoHom` | Destructors | Hom | Observation specs (field-parallel, Bool/Option) |
| 5 | `CoProduct` | Coproduct | Product | Observation results: what was seen |
| 6 | `Comonad` | Comonad | Monad | Traces: extract (current) + extend (history) |
| 7 | `CoIO` | Observer | IO | Observer executors: probes, not producers |

**Naming rule:** Category names are PascalCase. CoTypes categories are prefixed with `Co` (not `co`). The sole exception is `Comonad` (standard mathematical spelling, not `CoMonad`).

---

## 3. The 7-Phase Chain (Domain Layer)

Every lab defines its own 7-phase chain. Phases are domain-specific applications of the 7 categories. The phase name is domain-semantic; the type-theoretic identity is the invariant.

```
Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6 -> Phase 7
(Unit)     (ADT)      (Indexed)   (A -> B)   (AxB)      (M A)      (IO)
```

Phase names are defined in each lab's own TEMPLATE.md. The mapping from phase number to type-theoretic category is universal.

**Naming rule:** Phase names are PascalCase in directories, lowercase in justfile commands. Never kebab-case, never snake_case in directory names.

---

## 4. Directory Path Templates

Directory paths ARE type annotations. The path encodes: which half (Types/CoTypes), which category, which phase, and which role.

### Types/ Paths

```
Types/Identity/                          -- Category 1: terminal objects
Types/Inductive/                         -- Category 2: ADT variants
Types/Dependent/                         -- Category 3: indexed structures
Types/Hom/{Phase}/                       -- Category 4: phase input morphisms
Types/Product/{Phase}/Output/            -- Category 5: phase output
Types/Product/{Phase}/Meta/              -- Category 5: phase metadata
Types/Monad/                             -- Category 6: effect types
Types/IO/                                -- Category 7: build project root
Types/IO/IO{Phase}Phase/                 -- Category 7: phase IO executor
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
CoTypes/CoIO/CoIO{Phase}Phase/           -- CoCategory 7: phase observer executor
```

### IO Executor Naming

IO executor directories follow the pattern `IO{Phase}Phase`:

**Naming rule:** `IO` prefix, phase name in PascalCase, `Phase` suffix. Always. The `Co` variant prepends `Co` to the entire token: `CoIO{Phase}Phase`.

---

## 5. File Naming

### All Filenames Are `default.*`

**Every source file is named `default.*`.** The type identity is encoded entirely in the directory and subdirectory path -- never in the filename. This is the filesystem-as-type-system principle applied to naming.

| Language | Source File | IO Executor | JSON Boundary |
|----------|------------|-------------|---------------|
| Lean 4 | `Default.lean` | `default.nix` | `default.json` |
| Python | `default.py` | `default.py` | `default.json` |
| Rust | `default.rs` | `default.nix` | `default.json` |

The only exception is language-mandated init/module files (`__init__.py`, `mod.rs`, `lakefile.lean`, `lean-toolchain`).

Examples:

```
Types/Inductive/BootLoader/Default.lean   -- the type name is "BootLoader", the file is "Default.lean"
Types/Hom/Geometry/default.py             -- the type name is "GeometryHom", the file is "default.py"
Types/IO/IOIdentityPhase/default.nix      -- the executor name is "IOIdentityPhase", the file is "default.nix"
Types/IO/IOIdentityPhase/default.json     -- the boundary name is "IOIdentityPhase", the file is "default.json"
```

**Naming rule:** If you are tempted to name a file something other than `default.*`, the name belongs in the directory path instead. Create a subdirectory.

### Filetype Classification (FROZEN)

| Extension | Type Category | Rationale |
|-----------|--------------|-----------|
| Language source | Determined by directory | Type definitions: source of truth |
| `.nix` / executor | IO (under `Types/IO/` or `CoTypes/CoIO/`) | Effect executors |
| `.json` | IO boundary (`Types/IO/`) | Serialized Hom types |
| `.md` | CoIO / Comonad | Observation: describes without modifying |
| `.toml` | Dependent | Build parameterization: indexed over project |
| `.lock` | Identity | Terminal object: one canonical inhabitant |

Labs may add domain-specific extensions in their own TEMPLATE.md.

---

## 6. Type Naming Patterns

### Types/ (Abstract Patterns)

| Category | Pattern | Example |
|----------|---------|---------|
| Identity | `{Thing}` or `{Domain}Identity` | `Package`, `DesignIdentity` |
| Inductive | `{VariantName}` or `{Domain}Inductive` | `BootLoader`, `CadFormatInductive` |
| Dependent | `{ConfigName}` or `{Domain}Dependent` | `NixSettings`, `PrintProfileDependent` |
| Hom | `{Phase}Hom` | `IdentityHom`, `GeometryHom` |
| Product Output | `{Phase}Output` or `{Phase}ProductOutput` | `IdentityOutput`, `GeometryProductOutput` |
| Product Meta | `{Phase}Meta` or `{Phase}ProductMeta` | `IdentityMeta`, `GeometryProductMeta` |
| Monad | `{Effect}` or `{Effect}Monad` | `PhaseError`, `ErrorMonad` |

### CoTypes/ (Abstract Patterns)

| CoCategory | Pattern | Example |
|------------|---------|---------|
| CoIdentity | `Co{Thing}` or `Co{Domain}Identity` | `CoPackage`, `CoDesignIdentity` |
| CoInductive | `Co{Validator}` or `Co{Domain}Inductive` | `CoInductiveWitness` |
| CoDependent | `Co{ConfigName}` or `Co{Domain}Dependent` | `CoNixSettings` |
| CoHom | `Co{Phase}Hom` | `CoIdentityHom`, `CoGeometryHom` |
| CoProduct | `Co{Phase}Output` or `Co{Phase}ProductOutput` | `CoIdentityOutput` |
| Comonad | `Observation{Thing}` or `TraceComonad` | `ObservationEvent`, `TraceComonad` |
| CoIO | `Observation{Thing}` or `CoIO{Phase}Phase` | `ObservationResult` |

Labs choose one naming convention and apply it consistently. The `{Phase}Hom` / `Co{Phase}Hom` pattern is universal.

### Field Naming Rules

- Boolean observation fields: `{thing}Observed`, `{thing}Valid`, `{thing}Present` (or snake_case equivalents)
- No bare strings for finite variants: extract to `Types/Inductive/`
- No nullable/optional fields where a sentinel or default suffices
- All types derive serialization (ToJson/FromJson, pydantic BaseModel, serde, etc.)
- Maximum 7 fields per type (blowup prevention)

---

## 7. Justfile Command Naming

Every justfile command is a classified morphism. Three prefixes, no exceptions:

### Prefix Classification

| Prefix | Recursion Scheme | Direction | Maps To |
|--------|-----------------|-----------|---------|
| `ana-` | Anamorphism (unfold) | Artifact -> Evidence | CoTypes/ |
| `cata-` | Catamorphism (fold) | Types -> Artifact | Types/ |
| `hylo-` | Hylomorphism (unfold+fold) | Composite | Types/ tensor CoTypes/ |

### Command Naming Patterns

```
ana-{phase}              -- Observe a specific phase
ana-types-validate       -- Validate type schemas (roundtrip closure)
ana-{verb} {arg}         -- General observation
cata-{verb} {arg}        -- General production
cata-types-build         -- Build the type system
hylo-main {target}       -- Full pipeline (the event loop)
hylo-dev {shell}         -- Enter dev shell
```

**Naming rule:** All lowercase, kebab-case. Phase names in commands are lowercase (not PascalCase). No unprefixed commands except `default`.

---

## 8. Root-Level File Classification

Every file at the lab root has a type-theoretic classification:

| File | Type Category | Rationale |
|------|--------------|-----------|
| `flake.nix` / `pyproject.toml` / `Cargo.toml` | Hom (A -> B) or Dependent | Top-level morphism or build parameterization |
| `flake.lock` / `uv.lock` / `Cargo.lock` | Identity (top) | Terminal object: one canonical inhabitant |
| `justfile` | IO / CoIO | Dispatcher: each recipe is a classified morphism |
| `AGENTS.md` | CoIO | Observation of the system (agent instructions) |
| `README.md` | CoIO | Observation of the system (human documentation) |
| `DICTIONARY.md` | CoIO | Observation of the system (formal glossary) |
| `TRACKER.md` | CoIO | Observation of implementation state (progress) |
| `TEMPLATE.md` | CoIO | Observation of naming invariants |
| `.gitignore` | Dependent | Parameterizes what the git IO executor observes |

---

## 9. Git Commit Message Template

Commit messages are classified morphisms. The format:

```
[{Scope} | {Category}] v{Major}.{Minor}.{Patch}: {description}
```

### Scope (WHAT changed)

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
| `{Lab}` | Changes scoped to a specific lab |

### Category (TYPE of change)

| Category | Type Theory | When |
|----------|-------------|------|
| `Identity` | Terminal (new canonical form) | New lockfile, new pinned version |
| `Inductive` | ADT (new variant) | New enum, new sum type |
| `Dependent` | Indexed (parameterized) | New/changed indexed structure |
| `Hom` | Morphism (new arrow) | New phase input type |
| `Product` | Output (new result) | New phase output/meta |
| `Monad` | Effect (new side effect) | New error type, new result type |
| `IO` | Executor (new effect) | New/changed executor |
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

---

## 10. The Profunctor Pattern (per phase)

Every phase follows the same profunctor structure. This is the template for adding a new phase:

### Algebraic Side (Types/)

```
Types/Hom/{Phase}/                       -- Domain (input specification)
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom at IO boundary
Types/IO/IO{Phase}Phase/                 -- Arrow (effectful executor)
Types/Product/{Phase}/Output/            -- Codomain output
Types/Product/{Phase}/Meta/              -- Codomain metadata
```

### Coalgebraic Side (CoTypes/)

```
CoTypes/CoHom/   (Co{Phase}Hom)          -- What to check
CoTypes/CoIO/CoIO{Phase}Phase/           -- How to check (probe)
CoTypes/CoProduct/ (Co{Phase}Product)    -- What was seen
```

### Adding a New Phase (Checklist)

1. Name the phase (PascalCase, type-theoretically motivated)
2. Create `Types/Hom/{Phase}/` with `{Phase}Hom` type
3. Create `Types/Product/{Phase}/Output/` with `{Phase}Output` type
4. Create `Types/Product/{Phase}/Meta/` with `{Phase}Meta` type
5. Create `Types/IO/IO{Phase}Phase/` (IO executor + default.json)
6. Register in the lab's build system (lakefile, pyproject, Cargo.toml)
7. Add observation structures to CoTypes/ (CoHom, CoProduct)
8. Add `ana-{phase}` and `cata-{phase}` commands in justfile
9. Update TRACKER.md

---

## 11. Domain-Specific Names: WHERE They Live

Domain-specific naming (vendor names, tool names, application-specific identifiers) is NOT scattered across the codebase. It is precisely placed:

| Domain Name Type | WHERE It Lives | Example |
|-----------------|----------------|---------|
| Finite variants | `Types/Inductive/` | `BootLoader`, `CadFormat`, `McuFamily` |
| Config parameters | `Types/Dependent/` | `NixSettings.maxJobs`, `nozzle_dia_mm` |
| Phase input values | `Types/Hom/{Phase}/` | `IdentityHom.nixSettings`, `GeometryHom.operation` |
| Package/tool names | `Types/IO/IO{Phase}Phase/` | `pkgs.neovim`, `cadquery`, `probe-rs` |
| Deployment targets | `Types/Hom/{DeployPhase}/` | `HomeTarget`, board names |
| Build system inputs | Lab root build file | `nixpkgs`, `pydantic`, `embassy-rs` |

**Naming rule:** Vendor/tool names NEVER appear in Types/ category or phase names. They appear ONLY as:
1. Inductive constructors (e.g., `| systemdBoot | grub`, `fdm | sla | cnc`)
2. Dependent structure fields (e.g., `gitDelta : Bool`, `nozzle_dia_mm`)
3. IO executor implementation details (library calls, package attribute paths)

The type system is vendor-agnostic. The IO executors are vendor-specific.

---

## 12. Invariant Summary

1. Every name is a type. Directory placement IS typing.
2. 7 categories in Types/, 7 dual categories in CoTypes/. 1-1 correspondence.
3. Category names are PascalCase. Co-prefix for duals (except `Comonad`).
4. Phase names are PascalCase in directories, lowercase in justfile commands.
5. All filenames are `default.*`. The type name is the directory path. Only language-mandated exceptions (`__init__.py`, `mod.rs`, `lakefile.lean`).
6. IO executors: `IO{Phase}Phase`. CoIO observers: `CoIO{Phase}Phase`.
7. Type names follow `{Phase}Hom`, `{Phase}Output`, `{Phase}Meta`, `Co{Phase}Hom`, etc.
8. Justfile commands: `ana-` (observe), `cata-` (produce), `hylo-` (composite). No unprefixed commands.
9. Git commits: `[{Scope} | {Category}] v{M}.{m}.{p}: {description}`.
10. Domain-specific names live in Inductive (variants), Dependent (fields), and IO (implementations). Never in category or phase names.
11. Maximum 7 fields per type, 7 phases per module, 7 sub-phases per phase.
12. No nulls, no bare strings for enums, no upward imports in the DAG.
13. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual.
14. Names are first-class citizens. Every name carries type-theoretic weight. No ad-hoc naming. No exceptions.
