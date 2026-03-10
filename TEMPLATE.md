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
Types/IO/                                -- Category 7: IO executors
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

| Prefix | Recursion Scheme | Direction | Maps To | 6FF Functors |
|--------|-----------------|-----------|---------|--------------|
| `ana-` | Anamorphism (unfold) | Artifact -> Evidence | CoTypes/ | f* (pullback), f! (shriek pullback), Hom (internal) |
| `cata-` | Catamorphism (fold) | Types -> Artifact | Types/ | f* (pushforward), f! (shriek push) |
| `hylo-` | Hylomorphism (unfold+fold) | Composite | Types/ tensor CoTypes/ | x (tensor) |

### Sole Unprefixed Exception

`default` is the ONLY allowed unprefixed recipe. It is the identity morphism -- lists all recipes, produces zero effect. Every other recipe MUST be prefixed with `ana-`, `cata-`, or `hylo-`. No convenience shortcuts, no aliases, no abbreviations.

### 6FF Annotation Convention (Mandatory)

Every recipe MUST carry a 6FF annotation comment immediately above it. Format:

```
# {6FF functor} -- {Types/ or CoTypes/ target}: {description}
{prefix}-{name} *ARGS:
    ...
```

Example:

```
# f* pullback -- CoProduct/Identity: observe nix settings, secrets
ana-identity:
    @nix eval '.#homeConfigurations.darwin.config.nix' --json | jq .

# f! shriek push -- IO (Lake): build Lean type system
cata-types-build:
    @nix-shell -p lean4 --run "lake build"

# tensor -- ana-types-validate tensor cata-switch
hylo-main host="darwin": ana-types-validate (cata-switch host)
```

### Canonical Recipe Set (Per Lab)

Every lab MUST have at minimum:

| Recipe | Classification | Mandatory? |
|--------|---------------|------------|
| `default` | Identity (list recipes) | Yes |
| `hylo-main` | Hylomorphism (tensor: the event loop) | Yes |
| `cata-{phase}` | Catamorphism (one per production phase) | Yes (per phase) |
| `ana-{phase}` | Anamorphism (one per observation phase) | Yes (dual of each cata-) |
| `ana-check` | Anamorphism (cross-cutting validation) | Recommended |
| `ana-types-validate` | Anamorphism (roundtrip closure check) | Recommended |
| `cata-types-build` | Catamorphism (build Lean type system) | Recommended |

The duality invariant: **every `cata-{phase}` has an `ana-{phase}` dual.** Testing IS coalgebraic observation. There is no separate "test" command -- `ana-` commands ARE the tests.

### Dispatcher Pattern (Root Justfile)

The root `Universes/justfile` is a **dispatcher**. It delegates to lab justfiles. It does NOT duplicate lab recipes.

```
# Dispatch to lab justfiles
cata-system *ARGS:
    just -f SystemLab/justfile cata-{{ARGS}}
```

Lab justfiles are self-contained. Each lab's justfile contains the complete set of typed morphisms for that lab's artifact domain.

### Sub-Phase Rule

Sub-phase justfiles (nested inside `Types/IO/`) follow the same 6FF convention. No exceptions. If a phase has sub-phases with their own justfile, every recipe in that justfile is prefixed and annotated.

### Command Naming Patterns

```
ana-{phase}              -- Observe a specific phase
ana-types-validate       -- Validate type schemas (roundtrip closure)
ana-{verb} {arg}         -- General observation
cata-{verb} {arg}        -- General production
cata-types-build         -- Build the type system
hylo-main {target}       -- Full pipeline (the event loop)
```

**Naming rule:** All lowercase, kebab-case. Phase names in commands are lowercase (not PascalCase). No unprefixed commands except `default`.

---

## 8. Root-Level File Classification

Every file at the lab root has a type-theoretic classification:

| File | Type Category | Rationale |
|------|--------------|-----------|
| `flake.nix` / `pyproject.toml` / `Cargo.toml` | Hom (A -> B) or Dependent | Top-level morphism or build parameterization |
| `flake.lock` / `uv.lock` / `Cargo.lock` | Identity (top) | Terminal object: one canonical inhabitant |
| `lakefile.lean` / `Cargo.toml` (workspace) | Dependent | Build system parameterization (indexed over types) |
| `lean-toolchain` / `rust-toolchain.toml` | Identity (top) | Terminal object: one canonical toolchain version |
| `lake-manifest.json` | Identity (top) | Terminal object: one canonical dependency snapshot |
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

---

## 13. Sheaf Section Template: Onboarding a New Lab

The Type Universe is a sheaf F over the space of artifact domains. Each lab is a local section of that sheaf. Creating a new lab is reduced to instantiating 7 sections -- one per stratum of the information gradient. This template mechanizes that process.

### Step 0: Define the Base Point

**Question:** What typed artifact does this lab produce?

The answer defines the lab boundary (Invariant 28). One artifact type = one lab. If the answer names two independent artifact types, those are two labs.

| Field | Value |
|-------|-------|
| Lab name | `{Name}Lab` |
| Artifact type | (e.g., "NixOS system configurations", "3D-printed parts", "firmware images") |
| Type language | **Lean 4** (canonical, strata 1-6) |
| IO runtime | (e.g., Nix, Python, Cargo + Nix) -- stratum 7 only |

**Lean type core:** Every lab defines Lean 4 types for strata 1-6, regardless of what IO-layer language executes stratum 7. The Lean types are the source of truth. The IO-layer language reconstructs types from the JSON codec at the IO boundary. Labs that begin with IO-layer types (e.g., Python BaseModel) carry **provisional types** -- technical debt that must be replaced by Lean-generated projections. See Section 15 for the per-stratum projection table.

### Stratum 1: Identity (BEC) -- Trivial {e}, 0 DOF

**Question:** What are the frozen canonical forms that every phase references?

- **Types/Identity/**: Terminal objects with one canonical inhabitant (e.g., `Package`, `Version`, `Timestamp`)
- **CoTypes/CoIdentity/**: Introspection witnesses (present? installed? reachable?)
- **Constraint:** Zero degrees of freedom. ALL fields must have defaults. `Inhabited` and `BEq` mandatory.
- **Completeness:** Every shared primitive referenced by higher strata must originate here.

### Stratum 2: Inductive (Crystalline) -- Space group, finite discrete DOF

**Question:** What are the finite, enumerable choices in this domain?

- **Types/Inductive/**: ADTs / sum types (e.g., `BootLoader`, `CadFormat`, `McuFamily`)
- **CoTypes/CoInductive/**: Elimination forms, parsers, validators for each ADT
- **Constraint:** Finite zero-argument constructors only. Every string-that-is-an-enum lives here. Manual ToJson/FromJson (explicit catamorphism/anamorphism).
- **Completeness:** Every finite choice in the domain has an Inductive type. No bare strings.

### Stratum 3: Dependent (Liquid Crystal) -- Partial SO(3), indexed continuous DOF

**Question:** What structures are parameterized over discrete choices?

- **Types/Dependent/**: Indexed families fibered over Inductive types
- **CoTypes/CoDependent/**: Schema conformance validators (lifting property)
- **Constraint:** Primary form is a genuine dependent family (`abbrev Config (idx : Variant) : Type`). Pragmatic fallback: structure with at least one Inductive-typed field. <=7 fields. All defaults.
- **Completeness:** Every parameterized structure is here. No "config" objects scattered in IO.

### Stratum 4: Hom (Liquid) -- SO(3), continuous DOF

**Question:** What are the 7 phases, and what are their input specifications?

- **Types/Hom/{Phase}/**: Phase input morphisms composing Dependent types (uncurried profunctor domain)
- **CoTypes/CoHom/{Phase}/**: Observation specs (Bool/Option field-parallel to Hom)
- **Constraint:** <=7 phases. <=7 fields per Hom. All defaults (`{}` for Dependent fields). Named `{Phase}Hom`.
- **Completeness:** Every phase has a Hom type. The Hom type is the sole input to the IO executor.

### Stratum 5: Product (Gas) -- E(3), expanding DOF

**Question:** What does each phase produce?

- **Types/Product/{Phase}/Output/**: Phase output type (`{Phase}Output`)
- **Types/Product/{Phase}/Meta/**: Phase metadata type (`{Phase}Meta`, always includes `timestamp`)
- **CoTypes/CoProduct/{Phase}/**: Observation results (what the observer saw)
- **Constraint:** Every phase has Output + Meta. The categorical product is the codomain of the profunctor.
- **Completeness:** Every phase has both Output and Meta. No phase without a typed result.

### Stratum 6: Monad (Plasma) -- Gauge, charged DOF

**Question:** What can go wrong (or right) during IO execution?

- **Types/Monad/**: Effect types using Lean's native monad machinery (`ExceptT`, `MonadExcept`, monad transformer stacks, custom `Monad` instances)
- **CoTypes/Comonad/**: Observation traces (extract current + extend over history)
- **Constraint:** Error effects use `ExceptT`/`Except`. Custom result ADTs carry proper `Monad` instances. No plain `structure` with a `success : Bool` field.
- **Completeness:** Every failure mode and effect type in the domain is captured as a monad.

### Stratum 7: IO (QGP) -- Deconfined, maximal DOF

**Question:** What IO executors produce the artifacts?

- **Types/IO/IO{Phase}Phase/**: Executor (`default.{ext}`) + serialized Hom (`default.json`)
- **CoTypes/CoIO/CoIO{Phase}Phase/**: Observer executor (probes, does not modify)
- **Constraint:** Lean stops at stratum 6. IO is `default.json` + `default.{ext}`. No Lean types at this stratum -- only serialized boundaries and runtime executors.
- **Completeness:** Every phase has an IO executor + default.json. Every executor reads `cfg = merge(base, local)`.

### Completeness Checklist

- [ ] Lab name follows `{Name}Lab` convention
- [ ] 7 Types/ directories created (Identity, Inductive, Dependent, Hom, Product, Monad, IO)
- [ ] 7 CoTypes/ directories created (CoIdentity, CoInductive, CoDependent, CoHom, CoProduct, Comonad, CoIO)
- [ ] 7 phases named (PascalCase) and mapped to universal categories
- [ ] Each phase has the profunctor triad: Hom + IO executor + Product(Output + Meta)
- [ ] Each phase has the observation triad: CoHom + CoIO observer + CoProduct
- [ ] All `default.json` files committed with bounded defaults
- [ ] `local.json` pattern established (`.gitignore`'d)
- [ ] Justfile created with `ana-`/`cata-`/`hylo-` prefixed commands
- [ ] Lab-specific AGENTS.md, DICTIONARY.md, TEMPLATE.md, TRACKER.md created (extending Universes/ root)

---

## 14. Per-Stratum Lean Type Templates

Each stratum has a canonical Lean 4 syntactic form that encodes the stratum's symmetry group as precisely as Lean's type system allows. These are not style guidelines -- they are structural enforcement at the language level. Each Lean construct is chosen because it IS the category-theoretic object at that stratum, not because it approximates it.

### Stratum 1: Identity (BEC) -- Terminal Object

The terminal object has exactly one canonical inhabitant. Two sub-patterns:

**Pattern 1a: True Terminal Object** (zero fields, one constructor)

```lean
-- Types/Identity/{Name}/Default.lean
-- The terminal object: exactly one inhabitant, zero degrees of freedom.
inductive {Name} where
  | mk
  deriving Repr, BEq, Inhabited
```

**Invariant:** One nullary constructor. `Inhabited` witnesses the canonical form. `BEq` witnesses decidable equality (trivial -- all inhabitants are equal because there is only one). This IS the terminal object in the category of types.

**Pattern 1b: Shared Primitive** (canonical reference data)

```lean
-- Types/Identity/{Name}/Default.lean
-- Shared primitive: one canonical form per data node. All fields defaulted.
structure {Name} where
  field1 : Type1 := default1
  field2 : Type2 := default2
  deriving Repr, BEq, Inhabited, Lean.ToJson, Lean.FromJson
```

**Invariant:** ALL fields have defaults. `Inhabited` is mandatory (witnesses the existence of a canonical form). `BEq` is mandatory (decidable equality -- the trivial symmetry group). Use this when the terminal object carries identifying data (e.g., `Package` with `name` and `storePath`).

**When to use which:** 1a for pure witnesses (unit types, sentinel values). 1b for shared reference types that higher strata depend on.

### Stratum 2: Inductive (Crystalline) -- Free Algebra

The free algebra over a finite set of generators. The `inductive` keyword IS the type-theoretic construct.

```lean
-- Types/Inductive/{Name}/Default.lean
-- Free algebra: finite constructors, zero-argument. The space group is the
-- permutation group on constructors.
inductive {Name} where
  | variant1
  | variant2
  | variant3
  deriving Repr, BEq, Inhabited

-- Catamorphism (fold): elimination map to JSON serialization
instance : Lean.ToJson {Name} where
  toJson
    | .variant1 => "variant1"
    | .variant2 => "variant2"
    | .variant3 => "variant3"

-- Anamorphism (unfold): introduction map from JSON deserialization
instance : Lean.FromJson {Name} where
  fromJson? j := do
    let s <- j.getStr?
    match s with
    | "variant1" => pure .variant1
    | "variant2" => pure .variant2
    | "variant3" => pure .variant3
    | other => throw s!"unknown {Name}: {other}"
```

**Invariant:** Finite, zero-argument constructors only. No payload -- if a constructor needs data, the data lives in Dependent/ (stratum 3), indexed over this Inductive. Manual `ToJson`/`FromJson` instances are NOT a workaround -- they ARE the explicit catamorphism (fold to JSON) and anamorphism (unfold from JSON), the universal property of the free algebra. Pattern match exhaustiveness in `FromJson` is the **exhaustiveness witness**.

### Stratum 3: Dependent (Liquid Crystal) -- Fibration

A type that genuinely depends on a value from a lower stratum. The fibration: given an Inductive index, the fiber is a different type. Lean 4 is a dependently typed language -- use this.

**Primary Pattern: Genuine Dependent Family**

```lean
-- Types/Dependent/{Name}/Default.lean
-- Fibration: the type varies over the Inductive index.
-- Each fiber is a distinct structure inhabiting the total space.

structure {Name}ForVariant1 where
  param1 : Type1 := default1
  param2 : Type2 := default2
  deriving Repr, Lean.ToJson, Lean.FromJson

structure {Name}ForVariant2 where
  paramA : TypeA := defaultA
  deriving Repr, Lean.ToJson, Lean.FromJson

-- The dependent family: index -> Type
-- abbrev ensures transparent reduction during elaboration.
abbrev {Name} (idx : SomeInductive) : Type :=
  match idx with
  | .variant1 => {Name}ForVariant1
  | .variant2 => {Name}ForVariant2
```

**Invariant:** `abbrev` (not `def`) -- ensures Lean's elaborator can reduce `{Name} .variant1` to `{Name}ForVariant1` transparently. This is a genuine Pi type: `(idx : SomeInductive) -> Type`. The fiber over each index value is a structurally distinct type. This is the **section of the fibration**.

**Pragmatic Fallback: Soft Fibration**

```lean
-- Types/Dependent/{Name}/Default.lean
-- Soft fibration: at least one field references an Inductive type.
-- The structure is parameterized but not type-level indexed.
structure {Name} where
  index   : SomeInductive := SomeInductive.defaultVariant
  param1  : Type1 := default1
  param2  : Type2 := default2
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**When to use which:** Genuine dependent family when fibers are structurally different (different fields per variant). Soft fibration when all variants share the same field layout but are parameterized by an Inductive choice.

### Stratum 4: Hom (Liquid) -- Morphism Domain (Profunctor)

The domain of the profunctor `Hom(phase) --IO--> Product(phase)`. A Hom type is the uncurried input to a morphism -- the product of all Dependent types needed by a phase.

```lean
-- Types/Hom/{Phase}/Default.lean
-- Profunctor domain: the uncurried input to the phase morphism.
-- Hom(A,B) ~ A -> B by currying; this is the uncurried form.
structure {Phase}Hom where
  dep1 : DependentType1 := {}
  dep2 : DependentType2 := {}
  ind1 : InductiveType1 := default
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Invariant:** Composes Dependent and Inductive types from lower strata. <=7 fields. All defaults (`:= {}` for Dependent structures, `:= default` for Inductive types via `Inhabited`). Named `{Phase}Hom` -- the name declares it as the Hom-set for that phase. This IS the domain of the profunctor arrow.

### Stratum 5: Product (Gas) -- Categorical Product

The codomain of the profunctor. The categorical product A x B of Output and Meta. Lean's `structure` IS the product type (named fields are projections).

```lean
-- Types/Product/{Phase}/Output/Default.lean
-- Product projection 1: what the phase produced.
structure {Phase}Output where
  result1 : Type1 := default1
  result2 : Type2 := default2
  deriving Repr, Lean.ToJson, Lean.FromJson

-- Types/Product/{Phase}/Meta/Default.lean
-- Product projection 2: provenance metadata.
structure {Phase}Meta where
  timestamp : String := ""
  duration  : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Invariant:** Always paired: Output + Meta. This is the categorical product -- fields are projections (`output.result1`, `meta.timestamp`). Meta always includes `timestamp` (the observation timestamp is the minimal provenance witness). The Product stratum expands -- outputs proliferate as the phase chain progresses (E(3) symmetry: translations + rotations in output space).

### Stratum 6: Monad (Plasma) -- Effect Type

Effects carry side-channel information -- the "charge" of the Plasma stratum. Use Lean's native monad infrastructure: `Except`, `ExceptT`, `MonadExcept`, monad transformer stacks, and custom `Monad` instances. No plain structures pretending to be effects.

**Pattern 6a: Error Effect (ExceptT / Except)**

```lean
-- Types/Monad/{Phase}Error/Default.lean
-- The error payload: what goes wrong in this phase.
structure {Phase}Error where
  phase     : String
  message   : String
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

-- Types/Monad/{Phase}M/Default.lean
-- The phase monad: ExceptT over IO. Composes error handling with IO effects.
-- This IS the monad transformer stack for the phase.
abbrev {Phase}M (α : Type) := ExceptT {Phase}Error IO α
```

**Invariant:** `ExceptT` is the canonical error monad transformer. The phase monad `{Phase}M` composes `{Phase}Error` with `IO` via `ExceptT`. `do`-notation, `throw`, `try`/`catch` all work natively. `MonadExcept {Phase}Error {Phase}M` is derived automatically.

**Pattern 6b: Custom Result ADT with Monad Instance**

```lean
-- Types/Monad/{Name}/Default.lean
-- Custom result type: a proper monad with explicit bind semantics.
inductive {Name} (α : Type) where
  | ok    : α → {Name} α
  | error : String → {Name} α
  deriving Repr

-- The Monad instance gives us do-notation, >>=, pure.
-- Functor and Applicative are auto-derived from pure + bind.
instance : Monad {Name} where
  pure := {Name}.ok
  bind ma f := match ma with
    | .ok a    => f a
    | .error e => .error e
```

**Invariant:** The `Monad` instance is mandatory -- this is what makes it a monad, not just a data container. `Functor` and `Applicative` are auto-derived from `pure` + `bind`. Use this when the error type needs to be parametric or when you need monad laws to hold structurally.

**Pattern 6c: Composite Monad Stack (Multiple Effects)**

```lean
-- Types/Monad/{Name}/Default.lean
-- Composite effect: error + state + reader, stacked over IO.
abbrev {Name} (α : Type) :=
  ReaderT {Phase}Env (StateT {Phase}State (ExceptT {Phase}Error IO)) α
```

**Invariant:** Use monad transformer stacks (`ReaderT`, `StateT`, `ExceptT`) for composite effects. Each transformer adds one "charge" (one degree of freedom) to the effect. The gauge symmetry of the Plasma stratum is the monad transformer composition law: order of stacking matters (gauge choice).

### Stratum 7: IO (QGP) -- Deconfined

Lean's jurisdiction ends at stratum 6. Stratum 7 is the IO boundary: serialized types + runtime executors. No Lean type declarations here.

```
-- Types/IO/IO{Phase}Phase/default.json    (serialized Hom, committed)
-- Types/IO/IO{Phase}Phase/default.{ext}   (IO executor, runtime language)
-- Types/IO/IO{Phase}Phase/local.json      (site fiber, .gitignore'd)
```

**Invariant:** `default.json` is the serialized Hom at the IO boundary (the adjunction unit eta: `toJson`). The IO executor reads it (the adjunction counit epsilon: `fromJson`) and produces artifact state. Lean functions at this stratum use `IO α` directly or the phase monad from stratum 6:

```lean
-- Default.lean (lab root)
-- The entry point uses IO directly, or the phase monad stack.
def validatePhase (name : String) (path : System.FilePath)
    (α : Type) [Lean.FromJson α] : IO Bool := do
  ...

-- Or with the phase monad:
def runPhase (hom : {Phase}Hom) : {Phase}M {Phase}Output := do
  ...
```

### CoTypes Dual Templates

The coalgebraic dual of each stratum, using the most precise Lean construct available:

| Stratum | Types/ Construct | CoTypes/ Dual Construct |
|---------|-----------------|------------------------|
| 1 Identity | `inductive \| mk` or `structure` (Inhabited + BEq) | `structure Co{Name}` with `Bool` fields (`{field}Present : Bool`, `{field}Valid : Bool`) -- coterminal observation witnesses |
| 2 Inductive | `inductive` + manual ToJson/FromJson | Validation functions `{Name} → Bool` (exhaustiveness witness) + `String → Option {Name}` (parsing eliminator) |
| 3 Dependent | `abbrev {Name} (idx) : Type` (genuine fibration) | `abbrev Co{Name} (idx) : Type` (cofibration) with `Bool`/`Option` conformance fields per fiber |
| 4 Hom | `structure {Phase}Hom` (profunctor domain) | `structure Co{Phase}Hom` with `Bool`/`Option` observation fields (field-parallel destructors) |
| 5 Product | `structure {Phase}Output` + `{Phase}Meta` | `structure Co{Phase}Output` + `CoObservationMeta` (what was seen vs. what was expected) |
| 6 Monad | `ExceptT`/`Monad` instance/transformer stack | `structure` with `extract : W A → A` + `extend : (W A → B) → W A → W B` (comonad: trace observation) |
| 7 IO | `default.json` + `default.{ext}` (executor) | `default.json` (expected) + `default.{ext}` (observer: probe artifact, compare against CoHom) |

---

## 15. Lean-to-IO Projection Table

Lean 4 is the canonical DSL for strata 1-6. IO-layer languages reconstruct types from the JSON codec at the IO boundary. This table defines the projection functor P : Lean_Types -> IO_Types for each stratum and each supported IO-layer language.

The JSON boundary (`default.json`) is the universal codec. All projections factor through it:

```
Lean type  --toJson-->  default.json  --fromJson (IO lang)-->  IO-layer type
  (define)               (serialize)                             (reconstruct)
```

### Per-Stratum Projection

| Stratum | Lean 4 (Canonical) | JSON Schema | Python (pydantic) | Rust (serde) | Nix |
|---------|-------------------|-------------|-------------------|-------------|-----|
| 1 Identity | `inductive \| mk` or `structure` (Inhabited + BEq) | `{}` or `{"field": default}` | `class Name(BaseModel)` with defaults | `#[derive(Default, Deserialize)]` struct | attrset with defaults |
| 2 Inductive | `inductive` + manual ToJson/FromJson | `"variant"` (string enum) | `class Name(StrEnum)` | `#[derive(Deserialize)] enum` | string from finite set |
| 3 Dependent | `abbrev Name (idx) : Type` (fibration) | object with index field | `class Name(BaseModel)` with discriminated union | `#[serde(tag = "index")]` enum | attrset keyed by variant |
| 4 Hom | `structure {Phase}Hom` | nested object | `class {Phase}Hom(BaseModel)` | `#[derive(Deserialize)]` struct | attrset (the `default.json` itself) |
| 5 Product | `structure {Phase}Output` + `{Phase}Meta` | `{"output": {}, "meta": {}}` | `class {Phase}Output(BaseModel)` + `{Phase}Meta(BaseModel)` | paired structs | attrset with output + meta keys |
| 6 Monad | `ExceptT` / `Monad` instance / transformer | `{"ok": value}` or `{"error": msg}` | `try`/`except` + custom exception class | `Result<T, E>` | `builtins.tryEval` or `lib.throwIf` |
| 7 IO | `IO α` / `{Phase}M` | N/A (runtime) | `def main()` / `async def` | `fn main()` / `async fn` | `default.nix` (derivation or module) |

### Roundtrip Invariant

For every Lean type T at strata 1-6:

```
fromJson_{IO-lang}(toJson_{Lean}(t : T)) ≅ t
```

The JSON boundary preserves the type structure. The IO-layer reconstruction is faithful -- it recovers the same fields, constraints, and defaults as the Lean definition. If the IO-layer type diverges from the Lean type, the IO-layer type is wrong.

### Provisional Types

Labs that currently define types only in an IO-layer language (e.g., RL-Lab in Python, MaterialLab in Python) carry **provisional types**. These are technically correct at the IO boundary but lack the Lean-verified type core. They are technical debt:

- They MUST be replaced by Lean-generated projections as the Lean type core is built
- They do NOT extend the type theory -- they are temporary inhabitants of strata they do not own
- The migration path is: define Lean types -> generate `default.json` -> validate IO-layer types agree

---

## 16. Naming Normalization Protocol

Type names, phase names, and field names use **category-theoretic vocabulary exclusively**. Domain-specific jargon is confined to precisely three locations: Inductive variant constructors, IO-boundary fields (prefixed `io_`), and IO executor implementation internals. This is not a style preference -- it is a type-theoretic invariant. A name that uses domain jargon where a category-theoretic name exists is an ill-typed name.

### 16.1 Principle: Names ARE Types

Every name in the system carries type-theoretic weight. The name declares what the thing IS categorically, not what domain it comes from. When a category-theoretic name exists for a concept, it MUST be used. Domain-specific names are permitted only where they serve as opaque identifiers at the IO boundary (external API symbols, vendor protocol names, instrument identifiers).

### 16.2 Phase Name Normalization

Phase names are **type-theoretic verbs** describing the categorical operation performed, not domain-specific activities. The universal phase vocabulary:

| # | Type Theory | Canonical Verb | Anti-Pattern Verbs |
|---|-------------|---------------|-------------------|
| 1 | Unit (top) | Discovery | -- |
| 2 | Inductive (ADT) | Ingest | Download, Fetch, Load |
| 3 | Dependent (Indexed) | Transform | Feature, Engineer, Preprocess |
| 4 | Hom (A -> B) | Solve | Train, Learn, Fit |
| 5 | Product (A x B) | Eval | Test, Validate, Backtest |
| 6 | Monad (M A) | Project | Serve, Deploy, Execute |
| 7 | IO | Compose | Main, Pipeline, Orchestrate |

Labs may use domain-specific phase names ONLY when no category-theoretic verb applies. The burden of proof is on the domain name.

### 16.3 Type Name Normalization Rules

| Stratum | Naming Rule | Pattern | Anti-Pattern |
|---------|------------|---------|-------------|
| 1 Identity | Name what the terminal object indexes | `IndexIdentity`, `SessionIdentity` | `AssetIdentity`, `RunIdentity` |
| 2 Inductive | Name the categorical structure, not the domain format | `FrameInductive`, `CatalogInductive`, `SolverInductive` | `OHLCVInductive`, `ScreenerInductive`, `AlgoIdentity` |
| 3 Dependent | Name the type-theoretic role of the fiber | `ExecutionDependent`, `ConstraintDependent`, `FilterDependent` | `EnvDependent`, `RiskDependent`, `LiquidityDependent` |
| 4 Hom | `{Phase}Hom` using normalized phase name | `TransformHom`, `SolveHom`, `ProjectHom` | `FeatureHom`, `TrainHom`, `ServeHom` |
| 5 Product | `{Phase}ProductOutput` / `{Phase}ProductMeta` | `SolveProductOutput` | `TrainProductOutput` |
| 6 Monad | Name the effect category | `EffectMonad`, `SignalMonad`, `MeasureMonad` | `ObservabilityMonad`, `AlarmMonad`, `MetricMonad` |
| 7 IO | `IO{Phase}Phase` using normalized phase name | `IOTransformPhase`, `IOSolvePhase` | `IOFeaturePhase`, `IOTrainPhase` |

### 16.4 Field Name Normalization

| Domain Jargon | Category-Theoretic Name | Rationale |
|--------------|------------------------|-----------|
| `run_id` | `session_id` | A run is a session -- a bounded execution context with identity |
| `run_ts` | `session_ts` | Temporal coordinate of the session |
| `asset_type` | `index_class` | The asset is an index; its type is a class (variant of IndexClass) |
| `algo` | `solver` | An algorithm is a solver -- an optimization procedure |
| `n_envs` | `n_parallel` | Parallel instances, not "environments" |
| `total_timesteps` | `budget` | The training budget -- a bounded resource allocation |
| `episode_duration_min` | `horizon_min` | The planning horizon in minutes |
| `normalize_obs` | `normalize_input` | Input normalization, not "observation" normalization |
| `normalize_reward` | `normalize_signal` | Signal normalization, not "reward" normalization |
| `train_run_id` | `solve_session_id` | References which solve session to project |
| `optimize` | `search` | Hyperparameter search, not "optimization" |
| `optimize_config` | `search_fiber` | The dependent fiber parameterizing the search |
| `broker_mode` | `execution_mode` | Execution mode (sim/paper/live), not "broker mode" |
| `io_broker_key` | `io_execution_key` | IO-boundary key for the execution backend |
| `wavelet` | `basis` | A wavelet is a basis function family |
| `supertrend_period` | `envelope_period` | SuperTrend computes a price envelope |
| `supertrend_multiplier` | `envelope_multiplier` | Envelope width multiplier |
| `adx_period` | `trend_period` | ADX measures trend strength |
| `io_universe` | `io_indices` | A universe of assets is a collection of indices |
| `screener` | `catalog_source` | A screener produces a catalog |

### 16.5 Enum / Nested ADT Normalization

| Domain Jargon | Category-Theoretic Name | Location |
|--------------|------------------------|----------|
| `AssetType` | `IndexClass` | Identity (nested) |
| `HolidayCalendar` | `TemporalMask` | Identity (nested) |
| `BrokerMode` | `ExecutionMode` | Dependent (nested) |
| `ObjectiveMetric` | `ObjectiveInductive` | Dependent (nested) |
| `WaveletName` | `BasisInductive` | Hom (nested) |
| `ThresholdMode` | `ThresholdMode` | Hom (nested, already correct) |
| `MainStatus` | `ComposeStatus` | Product (nested) |
| `ServeStatus` | `ProjectStatus` | Product (nested) |
| `AlarmSeverity` | `SeverityInductive` | Inductive |
| `MetricKind` | `MeasureInductive` | Inductive |

### 16.6 Monadic Python Surface (`dry-python/returns`)

When a lab's IO runtime is Python, the `dry-python/returns` library provides the monadic surface that bridges Lean-verified types (strata 1-6) and Python IO executors (stratum 7). This is not optional for Python-runtime labs -- it is the projection of monadic purity from the Lean type core to the IO layer.

| `returns` Container | Maps To | Usage |
|----|------|------|
| `Result[T, E]` | Pure fallible computation | Parsing, validation, schema checks |
| `IOResult[T, E]` | Impure fallible computation | Every IO executor return type |
| `IO[T]` | Impure infallible computation | Timestamps, random seeds, file reads |
| `Maybe[T]` | Optional value (no None) | Store lookups, optional artifact retrieval |
| `RequiresContext[T, Deps]` | Dependency injection | Settings/config threading through call stacks |
| `flow()` / `pipe()` | Sequential composition | Pipeline phase chaining |
| `@safe` / `@impure_safe` | Exception capture | Auto-wraps exceptions into `Failure` |

### 16.7 Where Domain Names ARE Permitted

Domain-specific terms are not eliminated -- they are **precisely placed**:

| Location | What Lives There | Example |
|----------|-----------------|---------|
| Inductive variant constructors | Vendor/protocol/format names | `PPO`, `SAC`, `DQN`, `A2C` (solver variants) |
| IO-boundary fields (`io_` prefix) | External identifiers | `io_ticker`, `io_indices`, `io_execution_key` |
| IO executor internals | Library calls, API names | `yf.download()`, `alpaca.submit_order()` |
| `default.json` values | Concrete runtime values | `"PPO"`, `"AAPL"`, `"paper"` |
| Documentation (DICTIONARY.md) | Domain term definitions | "ADX measures trend strength on a 0-100 scale" |

The type system is domain-agnostic. The IO layer is domain-specific. The boundary between them is `default.json`.
