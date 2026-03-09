# AGENTS.md

Agent-optimized context for the Universes monorepo. This is the **single source of truth** for all type-theoretic invariants, design patterns, and architectural principles that apply universally across every lab.

Lab-specific AGENTS.md files extend this document with domain-specific rules.

---

## Scope

This is a **solo-researcher system** -- one human operator building typed artifact factories. The formalism described in this document is not a style preference or an aspirational architecture. It IS the system. Deviating from it is not "breaking a rule" -- it is producing an ill-typed artifact.

**Lean 4 is the formal backbone.** The 7-category filesystem structure is a type theory that Lean verifies at compile time. Other languages (Python, Rust, Nix) are IO-layer executors: they read typed JSON at the IO boundary and execute effectful morphisms, but they do not define or extend the type theory. The types are the single source of truth.

**The matter-phase naming (BEC -> Crystalline -> Liquid Crystal -> Liquid -> Gas -> Plasma -> QGP) is geometric binding**, not decoration. It reflects a stratified symmetry-breaking hierarchy where each stratum has strictly more degrees of freedom than the one below. The symmetry groups (trivial -> space group -> partial SO(3) -> SO(3) -> E(3) -> gauge -> deconfined) are the geometric backbone. See `DICTIONARY.md` for the full stratified information gradient and the comprehensive CS/DevOps -> type theory mapping.

**Every CS/DevOps/infrastructure concept has a category-theoretic grounding.** CI/CD is a hylomorphism. Feature flags are dependent types indexed over a boolean fiber. Caching is a memoized morphism (idempotent endofunctor). Microservices are products of profunctors. If a concept cannot be grounded in the formalism, it is not understood yet -- and ununderstood concepts do not enter the system.

---

## Sheaf-Theoretic Frame

The Type Universe has the structure of a **sheaf** F over the space of artifact domains:

- **Each lab is a section** of F -- a local instantiation of the 7-stratum type system for a specific artifact domain.
- **The 7 strata are the fiber** at each point -- Identity through IO, with strictly increasing degrees of freedom.
- **The universal invariants** (31 items below) are the **restriction maps** -- constraints that every section must satisfy.
- **The 6-functor formalism** provides the canonical allowed morphisms between fibers and between sections.
- **Lean 4 types the total space.** The compile-time verification of Lean types is the proof that local sections are well-formed. IO-layer languages (Nix, Python, Rust) inhabit the stalks -- they execute within a single fiber but do not define the sheaf structure.
- **External libraries and packages are function calls at the IO boundary**, typed and bounded by the Lean-verified sheaf structure. They do not extend the type theory; they are invoked by it.
- **Creating a new lab** = choosing a base point (artifact domain) and instantiating 7 sections (see TEMPLATE.md Section 13).
- **The gluing condition** ensures labs sharing types (e.g., shared Identity types) must agree on definitions. The monorepo is globally consistent, not just locally.

See `DICTIONARY.md` for formal definitions of sheaf, section, stalk, fiber, restriction map, gluing, and descent.

---

## Architecture

A **lab** is a typed artifact factory. Every lab follows the same architecture:

```
Lean 4 (strata 1-6)  ->  default.json  ->  IO executor ({Runtime language})
canonical types            IO boundary       effectful projection
```

- **Types/** defines the algebraic (constructive, catamorphic) side -- **always in Lean 4**
- **CoTypes/** defines the coalgebraic (observational, anamorphic) dual -- **always in Lean 4**
- **default.json** is the serialized Hom at the IO boundary -- the **codec** between Lean and the IO layer
- **IO executors** read JSON and produce effectful output in the lab's runtime language (Nix, Python, Rust, etc.)

Lean 4 is the **sole authority** for strata 1-6. The IO-layer language is confined to stratum 7. The type-theoretic structure is invariant across all labs; only the IO runtime varies.

---

## Lean Canonical Primacy

**Lean 4 is the canonical DSL for the entire Type Universe. This is not optional.**

Adherence to the type-theoretic framework and mathematical purity is an unconditional requirement. It is never compromised for convenience, speed, tooling limitations, or ad-hoc decisions. Violations indicate a flawed understanding of requirements, not a pragmatic trade-off. The formalism IS the system. Deviating from it does not produce "imperfect but working" code -- it produces an ill-typed artifact that is definitionally incorrect.

**The Lean-IO boundary is a projection functor:**

```
P : Lean_Types (strata 1-6)  -->  IO_Types (stratum 7)

Lean type  --toJson-->  default.json  --fromJson (IO lang)-->  IO-layer type
  (source of truth)      (codec)                                (projection)
```

- **Lean defines.** Strata 1-6 (Identity through Monad) are defined in Lean 4 for every lab. No exceptions.
- **JSON serializes.** `default.json` is the adjunction unit (eta): it serializes the Lean-typed Hom into a language-agnostic boundary.
- **IO-layer reconstructs.** The IO-layer language (Python `BaseModel`, Rust `#[derive(Deserialize)]`, Nix `builtins.fromJSON`) reconstructs the type from JSON. This is the adjunction counit (epsilon).
- **Roundtrip closure holds.** `fromJson(toJson(leanType)) ≅ leanType`. The JSON boundary is the witness.

**For labs that do not yet have Lean types** (e.g., RL-Lab, MaterialLab with Python-native types): the IO-layer types are **provisional**. They are placeholders that MUST be replaced by Lean-generated projections as the Lean type core is built. Provisional types are technical debt against the formalism, not an accepted alternative.

See `DICTIONARY.md` for formal definitions of Projection Functor and Codec. See `TEMPLATE.md` Section 15 for the per-stratum Lean-to-IO projection table.

---

## Doc Updates

After every output, update TRACKER.md, DICTIONARY.md, TEMPLATE.md and AGENTS.md files where applicable, referencing/refreshing your context on them before every input and output.

When working inside a lab, read **both** this file and the lab's own AGENTS.md.

---

## Directory Placement IS Typing

Every file in a lab belongs to exactly one of 14 directories (7 Types + 7 CoTypes). The directory path IS the type annotation. Placing a file in `Types/Hom/{Phase}/` declares it as a morphism into that phase. There is no separate type declaration -- the filesystem is the type system.

If a file cannot be classified into exactly one of the 14 categories, either the file should not exist, or a category is missing.

---

## Filetype Classification

Every file extension maps to a type category. Language-specific extensions (`.lean`, `.py`, `.rs`) are determined by directory placement. Universal mappings:

| Extension | Category | Rationale |
|-----------|----------|-----------|
| Language source | Any (determined by directory) | Type definitions -- the source of truth |
| `.nix` / executor script | IO (always `Types/IO/` or `CoTypes/CoIO/`) | Effect executors |
| `.json` | IO boundary (`Types/IO/`) | Serialized Hom types at the IO boundary |
| `.md` | CoIO / Comonad | Observation / documentation -- describes without modifying |
| `.toml` | Dependent | Build parameterization -- indexed over project identity |
| `.lock` | Identity | Terminal object -- one canonical inhabitant |

Labs may add domain-specific extensions (e.g., `.stl`, `.gcode`, `.svd`) in their own AGENTS.md.

---

## The Profunctor Pattern

Every phase is a profunctor: `Hom -> Product` via an IO executor.

```
Hom(phase)  --IO executor-->  Product(phase)
  (domain)                       (codomain)
```

- `Hom/` types are the **domain** -- bounded, normalized inputs (what was called "config")
- `Product/` types are the **codomain** -- phase outputs + meta
- `Types/IO/IO{Phase}Phase/` is the **arrow** -- the effectful profunctor implementation
- `default.json` is the **serialized Hom** at the IO boundary

There are no "configurations" -- there are dependent types serving as domains of morphisms.

---

## Observation Pipeline (Coalgebraic Dual)

Production and observation are dual paths that must agree. The system has two observation modes:

### Path (a): Schema Observation (pure, type-level)

```
Hom(phase)  --toJson-->  default.json  --fromJson-->  Hom(phase)
              (unit n)                    (counit e)
```

Roundtrip closure: `fromJson . toJson = id`. The JSON boundary is the witness.

### Path (b): Runtime Observation (effectful, system-level)

```
Product(phase)  --CoIO observer-->  CoProduct(phase)
   (what was built)   (probe)          (what was seen)
```

The CoIO observer probes the produced artifact and populates CoProduct -- the observation result.

### Commutativity Invariant

Both paths must agree:

```
         Hom --IO--> Product
                        |
                   (a)  |  (b)
                        |
                        v
                    CoProduct
                        ^
                        |
                  [produced artifact]
```

Path (a) destructures the typed output (Product -> CoProduct). Path (b) probes the live artifact ([produced artifact] -> CoProduct). Agreement between (a) and (b) is the **bidirectional path closure** -- the proof that the IO executor did what the types said it would.

- **Production** (Types/ -> IO -> Product) is the **free** direction -- constructive, information-preserving.
- **Observation** (Product -> CoIO -> CoProduct) is the **forgetful** direction -- observational, information-losing.
- The **free-forgetful adjunction** `F -| U` between them is the formal statement that the system is well-typed: what you build is what you observe, modulo the forgotten construction path.

CoTypes/ is the **bidirectional path closure witness**: schema test + runtime validation. Both paths yield CoProduct. If they agree, the system is correct.

---

## CoTypes Observation Triad

Every phase has an observation triad (dual of the production profunctor):

```
CoHom(phase)  --CoIO observer-->  CoProduct(phase)
  (what to check)   (probe)         (what was seen)
```

- `CoHom/` types are the **observation specification** -- what to check, field-parallel to Hom/
- `CoProduct/` types are the **observation result** -- what was actually seen (Output + Meta)
- `CoTypes/CoIO/CoIO{Phase}Phase/` is the **observer executor** -- the effectful probe
- CoHom mirrors Hom field-for-field but with observation types (Bool for "is this set?", Option for "what did we see?")

| Component | Types/ (Production) | CoTypes/ (Observation) |
|-----------|--------------------|-----------------------|
| Specification | `Hom/{Phase}/` -- what to provide | `CoHom/{Phase}/` -- what to check |
| Executor | `IO/IO{Phase}Phase/` -- produce artifact | `CoIO/CoIO{Phase}Phase/` -- probe artifact |
| Result | `Product/{Phase}/` -- what was produced | `CoProduct/{Phase}/` -- what was observed |
| Effect type | `Monad/` -- errors, build results | `Comonad/` -- observation traces, history |

---

## Type-Theoretic Categories (7)

Every type in the system belongs to exactly one of 7 categories. No exceptions.

| # | Category | Type Theory | Matter | Symmetry | Directory |
|---|----------|-------------|--------|----------|-----------|
| 1 | Identity | Unit (top) | BEC | Trivial {e} | `Types/Identity/` |
| 2 | Inductive | ADT / Sum | Crystalline | Space group | `Types/Inductive/` |
| 3 | Dependent | Indexed / Fibered | Liquid Crystal | Partial SO(3) | `Types/Dependent/` |
| 4 | Hom | Function (A -> B) | Liquid | SO(3) | `Types/Hom/` |
| 5 | Product | Product / Sum | Gas | E(3) | `Types/Product/` |
| 6 | Monad | Monad (M A) | Plasma | Gauge | `Types/Monad/` |
| 7 | IO | IO | QGP | Deconfined | `Types/IO/` |

Fractal: same 7 categories recurse at every level.

---

## Coalgebraic Dual (1-1 Correspondence)

Every category in Types/ has exactly one dual in CoTypes/. No exceptions.

| # | Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|---|--------|----------|---------|-------------------|
| 1 | `Identity/` | `CoIdentity/` | Terminal <-> Coterminal | Introspection witnesses -- present? installed? reachable? |
| 2 | `Inductive/` | `CoInductive/` | Free <-> Cofree | Elimination forms -- parsers, validators, exhaustiveness witnesses |
| 3 | `Dependent/` | `CoDependent/` | Fibration <-> Cofibration | Lifting property -- schema conformance validators |
| 4 | `Hom/` | `CoHom/` | Constructors <-> Destructors | Observation specifications -- field-parallel with observation types |
| 5 | `Product/` | `CoProduct/` | Product <-> Coproduct | Observation results -- what the observer actually saw per phase |
| 6 | `Monad/` | `Comonad/` | Effects <-> Co-effects | Observation traces -- extract (current) + extend (history) |
| 7 | `IO/` | `CoIO/` | Executors <-> Observers | Observer executors -- probe artifact state, compare against CoHom |

---

## Justfile Commands as Functors (6-Functor Formalism)

Every justfile command is a morphism classified by the 6-functor formalism (Grothendieck):

```
f* -| f*    (pullback -| pushforward)         -- inverse/direct image
f! -| f!    (shriek pullback -| shriek push)  -- compact support
x  -| Hom   (tensor -| internal hom)          -- monoidal structure
```

Three command prefixes:

| Prefix | Recursion Scheme | 6FF Functors | Direction | Maps to |
|--------|-----------------|--------------|-----------|---------|
| `ana-` | Anamorphism (unfold) | f*, f!, Hom | Observe / extract | CoTypes/ |
| `cata-` | Catamorphism (fold) | f*, f! | Produce / deploy | Types/ |
| `hylo-` | Hylomorphism (unfold+fold) | x (tensor) | Composite: ana then cata | Types/ x CoTypes/ |

**Testing = coalgebraic observation.** Every `cata-*` has an `ana-*` dual. Validation is not a separate concern -- it is the CoIO mapping of the IO executor.

### 6FF Classification

| 6FF Functor | Prefix | Meaning | Example |
|-------------|--------|---------|---------|
| f* (pullback) | `ana-` | Pull back observable data | `ana-show`, `ana-{phase}` |
| f! (shriek pullback) | `ana-` | Validation that may fail | `ana-check`, `ana-types-validate` |
| Hom (internal) | `ana-` | List/enumerate structure | `ana-keys`, `ana-list` |
| f* (pushforward) | `cata-` | Push typed data into system | `cata-switch`, `cata-deploy` |
| f! (shriek push) | `cata-` | Production with side effects | `cata-build`, `cata-types-build` |
| x (tensor) | `hylo-` | Composite: observe then produce | `hylo-main` |

---

## Import DAG (strictly layered)

```
Identity <- Inductive <- Dependent <- Hom <- Product
                                           ^
                                     Monad
                                           ^
                                      IO
```

No upward imports. Monad and IO are terminal -- they may reference all lower layers.

CoTypes may import Types (crossing the algebra/coalgebra boundary downward):

```
CoTypes.CoInductive  <- Types.Inductive     (elimination needs constructors)
CoTypes.CoDependent  <- Types.Inductive     (lifting needs fiber index)
CoTypes.CoHom        <- CoTypes.CoDependent (observation specs reference cofibrations)
CoTypes.CoIO         <- CoTypes.CoProduct   (observer results reference observation outputs)
CoTypes.CoIO         <- CoTypes.Comonad     (observer results reference traces)
```

---

## Invariants

These apply to **every lab** in the Universes monorepo. No exceptions.

1. Types/ and CoTypes/ are the only top-level source directories in each lab. The lab root IS the type universe.
2. Every type belongs to exactly one of 7 categories: Identity, Inductive, Dependent, Hom, Product, Monad, IO.
3. Every category in Types/ has exactly one dual in CoTypes/. 1-1 correspondence. No exceptions.
4. One type per file -- each type definition file contains exactly one primary type declaration. Re-export files aggregate sub-modules.
5. IO/ is capped at 7 subdirectories -- the 7 canonical phases of artifact production.
6. All filenames are `default.*` -- the type name is encoded in the directory path, never the filename. (`Default.lean`, `default.py`, `default.rs`, `default.nix`, `default.json`). The only exceptions are language-mandated files (`__init__.py`, `mod.rs`, `lakefile.lean`, `lean-toolchain`).
7. NO import-tree. IOMainPhase imports phases 1-6 and implements phase 7.
8. NO options blocks or dynamic typing in IO executors. All typing lives in Types/.
9. NO nulls -- all params bounded with defaults in type definitions.
10. NO vendor names in Types/ category or phase names. Handle in Inductive constructors, Dependent fields, and IO executors.
11. NO bare strings for finite variants. Every string-that-is-an-enum is an Inductive ADT.
12. Import DAG is strictly layered: Identity <- Inductive <- Dependent <- Hom <- Product. No upward imports.
13. Monad and IO are terminal in the import DAG -- they may reference all lower layers.
14. 1-1-1 invariant: every Phase has Hom x Product(Output + Meta) x IO executor.
15. <=7 phases per module. <=7 fields per type.
16. default.json is committed (like a lock file). Regenerated via `ana-types-validate`.
17. Every `just` command is a classified morphism: `ana-` (coalgebraic), `cata-` (algebraic), or `hylo-` (tensor). No unprefixed commands.
18. Directory placement IS typing. The path is the type annotation. No exceptions.
19. Every filetype has a canonical category. No unclassified filetypes.
20. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual.
21. The 6-functor formalism classifies all morphisms.
22. Phase placement is determined solely by type theory -- not domain convenience.
23. Invariants are never traded away for convenience. No exceptions.
24. Docs first. Always.
25. CoTypes/ is the bidirectional path closure witness: schema test (path a) + runtime validation (path b). Both paths yield CoProduct. Agreement = correctness.
26. Local override pattern: `default.json` (Identity, committed) + `local.json` (Dependent, .gitignore'd) merged by IO executor. Machine-specific data NEVER in committed JSON.
27. Every IO executor reads `cfg = merge(base, local)` where `local` falls back to `{}` when `local.json` absent.
28. Project boundary = artifact type. "What typed artifact are we producing?" defines the lab boundary.
29. Fractal self-similarity -- if a phase needs sub-phases, apply the same 7-category structure recursively.
30. Minimal orthogonal generating set -- at each stratum, the minimum necessary types/subdirs to span the space.
31. Sub-projects with their own type systems are **separate labs** (or sub-universes) with own Types/CoTypes. Not sub-directories of an existing lab.
32. Lean 4 is the canonical DSL for strata 1-6 in every lab. IO-layer languages (Python, Rust, Nix) inhabit stratum 7 only. IO-layer types are projections of Lean types via the JSON codec, not independent definitions. Labs without Lean types yet carry provisional IO-layer types -- technical debt, not an accepted alternative.

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Pattern |
|-------------|---------------|-----------------|
| Options blocks / dynamic typing in IO executors | Typing lives in Types/ | IO executors read typed JSON |
| Import-tree (auto-discovery) | Explicit is better | IOMainPhase explicitly imports phases 1-6 |
| Vendor names in Types/ categories | Categories are type-theoretic | Vendor names are Inductive constructors |
| `null` / `""` / `None` as default | Not bounded | Explicit bounded default in type definition |
| Type with >7 fields | Spans multiple symmetry groups | Decompose into sub-structures |
| Bare `String` for finite variant | Not exhaustively checkable | Extract to `Inductive/` as ADT |
| File outside canonical 7-category dir | Untyped | Move to correct category |
| Unprefixed justfile recipe | Not decodable | Classify as ana-/cata-/hylo- |
| Missing CoTypes dual | Breaks 1-1 correspondence | Every Types/ category has a CoTypes/ dual |
| Upward import in DAG | Dependency inversion | Follow strict layering |
| Using the word "config" | Misleading abstraction | It is a dependent type serving as the domain of a morphism |
| Sub-project inside a phase dir | Conflates domains | Separate lab with own Types/CoTypes |
| Speculative type additions | Violates minimal generating set | Add types only when empirically motivated |
| IO-layer types without Lean backing | Lean is the canonical DSL; IO-layer types are projections | Define Lean types at strata 1-6 first, then project to IO-layer language |
| Compromising formalism for convenience | Violations are ill-typed artifacts, not trade-offs | The formalism IS the system; adherence is unconditional |
