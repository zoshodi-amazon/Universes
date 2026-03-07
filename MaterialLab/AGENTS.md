# AGENTS.md

Agent-optimized context for the MaterialLab universe.

Pattern Version: v0.1.0 | Structure: FROZEN

## Doc Updates

After every output, update TRACKER.md, DICTIONARY.md, TEMPLATE.md and AGENTS.md files where applicable, referencing/refreshing your context on them before every input and output.

## Domain Boundary

This Universe produces **physical material artifacts** — 3D prints, CNC-machined parts, laser-cut assemblies, fabrication designs. The domain is closed around: one operator × N manufacturing targets (3D printers, CNC mills, laser cutters, manufacturing lines). The end artifact is a complete, reproducible, type-checked design file deployable to a manufacturing endpoint.

**"Done"** = any design in the catalog can be produced by `hylo-main {design}` and fully observed at every stratum by the 7 CoIO observers (`ana-{phase}`).

## Architecture

```
Types/ (Python)  →  default.json  →  Types/IO/ (Python)
7-category DSL      IO boundary      IO executors (pydantic-settings → run())

CoTypes/ (Python) — Coalgebraic dual of Types/ (1-1 correspondence)
```

## Directory Placement IS Typing

Every file in the repository belongs to exactly one of 14 directories (7 Types + 7 CoTypes). The directory path IS the type annotation. Placing a file in `Types/Hom/Geometry/` declares it as a morphism into the Geometry phase. There is no separate type declaration — the filesystem is the type system.

If a file cannot be classified into exactly one of the 14 categories, either the file should not exist, or a category is missing.

## Filetype Classification

Every file extension maps to a type category:

| Extension | Category | Rationale |
|-----------|----------|-----------|
| `.py` | Any (determined by directory) | Type definitions and IO executors |
| `.json` | IO boundary (`Types/IO/` or `CoTypes/IO/`) | Serialized Hom types at the IO boundary |
| `.md` | CoIO / Comonad | Observation / documentation — describes without modifying |
| `.toml` | Dependent | Build parameterization — indexed over project identity |
| `.lock` | Identity | Terminal object — one canonical inhabitant |

Repo-root files:

| File | Type | Rationale |
|------|------|-----------|
| `justfile` | IO / CoIO | Dispatcher — each recipe is a classified morphism |
| `pyproject.toml` | Dependent | Build parameterization |
| `AGENTS.md` | CoIO | Observation of the system (documentation) |
| `README.md` | CoIO | Observation of the system (documentation) |
| `DICTIONARY.md` | CoIO | Observation of the system (formal glossary) |
| `TRACKER.md` | CoIO | Observation of implementation state (progress) |
| `TEMPLATE.md` | CoIO | Observation of naming invariants |
| `.gitignore` | Dependent | Parameterizes what the git IO executor observes |

## Phase Chain

```
Discovery -> Ingest -> Geometry -> Simulation -> Fabrication -> Verify -> Main
(Unit/top)   (ADT)     (Indexed)   (A -> B)      (AxB)          (M A)    (IO)
```

7 phases. Each phase IS a type-theoretic category applied to the material fabrication domain. The phase name is domain-semantic; the type-theoretic identity is the invariant.

| # | Phase | Type Theory | Matter | Domain |
|---|-------|-------------|--------|--------|
| 1 | Discovery | Unit (top) | BEC | Catalog search: existing designs, material databases, part libraries |
| 2 | Ingest | Inductive (ADT) | Crystalline | Import/parse: CAD files (STEP, STL, 3MF), material property sheets |
| 3 | Geometry | Dependent (Indexed) | Liquid Crystal | Parametric modeling: CadQuery CSG, mesh ops, filleting, extrusions |
| 4 | Simulation | Hom (A -> B) | Liquid | Analysis: FEA stress (sfepy), thermal, topology optimization |
| 5 | Fabrication | Product (AxB) | Gas | Manufacturing: slicing, toolpath generation, G-code output |
| 6 | Verify | Monad (M A) | Plasma | Conformance: dimensional analysis, tolerance checking, printability |
| 7 | Main | IO | QGP | Orchestration: full pipeline, deploy to printer/CNC/manufacturing |

## Profunctor Pattern

Every phase is a profunctor: `Hom -> Product` via an IO executor.

```
Hom(phase)  --IO executor--▸  Product(phase)
  (domain)    (default.py)       (codomain)
```

- `Hom/` types are the **domain** — bounded, normalized inputs
- `Product/` types are the **codomain** — phase outputs + meta
- `Types/IO/IO{Phase}Phase/default.py` is the **arrow** — the effectful profunctor implementation
- `default.json` is the **serialized Hom** at the IO boundary

## Observation Pipeline (Coalgebraic Dual)

Production and observation are dual paths that must agree. The system has two observation modes:

### Path (a): Schema Observation (pure, type-level)

```
Hom(phase)  --to_json--▸  default.json  --from_json--▸  Hom(phase)
```

Roundtrip closure: `from_json . to_json = id`. The JSON boundary is the witness.

### Path (b): Runtime Observation (effectful, system-level)

```
Product(phase)  --CoIO observer--▸  CoProduct(phase)
   (what was built)   (probe)          (what was seen)
```

The CoIO observer probes the produced artifact and populates CoProduct — the observation result.

### Commutativity Invariant

Both paths must agree. CoTypes/ is the bidirectional path closure witness.

## CoTypes Observation Triad

Every phase has an observation triad (dual of the production profunctor):

```
CoHom(phase)  --CoIO observer--▸  CoProduct(phase)
  (what to check)   (probe)         (what was seen)
```

| Component | Types/ (Production) | CoTypes/ (Observation) |
|-----------|--------------------|-----------------------|
| Specification | `Hom/{Phase}/` — what to provide | `CoHom/Co{Phase}/` — what to check |
| Executor | `IO/IO{Phase}Phase/` — produce artifact | `IO/CoIO{Phase}Phase/` — probe artifact |
| Result | `Product/{Phase}/` — what was produced | `CoProduct/Co{Phase}/` — what was observed |
| Effect type | `Monad/` — errors, metrics, alarms | `Comonad/` — observation traces |

## Type-Theoretic Categories (7)

Every type in the system belongs to exactly one of 7 categories. No exceptions.

| # | Category | Type Theory | Matter | Directory |
|---|----------|-------------|--------|-----------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` |
| 2 | Inductive | ADT / Sum | Crystalline | `Types/Inductive/` |
| 3 | Dependent | Indexed / Fibered | Liquid Crystal | `Types/Dependent/` |
| 4 | Hom | Function (A -> B) | Liquid | `Types/Hom/` |
| 5 | Product | Product (AxB) | Gas | `Types/Product/` |
| 6 | Monad | Monad (M A) | Plasma | `Types/Monad/` |
| 7 | IO | IO | QGP | `Types/IO/` |

## Coalgebraic Dual (1-1 Correspondence)

Every category in Types/ has exactly one dual in CoTypes/. No exceptions.

| # | Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|---|--------|----------|---------|-------------------|
| 1 | `Identity/` | `CoIdentity/` | Terminal <-> Coterminal | Introspection witnesses — design exists? files present? |
| 2 | `Inductive/` | `CoInductive/` | Free <-> Cofree | Elimination forms — mesh validators, format parsers |
| 3 | `Dependent/` | `CoDependent/` | Fibration <-> Cofibration | Schema conformance — print profile valid for machine? |
| 4 | `Hom/` | `CoHom/` | Constructors <-> Destructors | Observation specs — field-parallel to Hom/ |
| 5 | `Product/` | `CoProduct/` | Product <-> Coproduct | Observation results — what the observer saw per phase |
| 6 | `Monad/` | `Comonad/` | Effects <-> Co-effects | Traces — extract (current) + extend (history) |
| 7 | `IO/` | `IO/` | Executors <-> Observers | Observer executors — probe artifacts and compare |

## 1-1 Phase Mapping

Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry. No exceptions.

| Phase | Hom | ProductOutput | IO Executor | justfile |
|-------|-----|---------------|-------------|----------|
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `cata-discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `cata-ingest` |
| Geometry | GeometryHom | GeometryProductOutput | IOGeometryPhase | `cata-geometry` |
| Simulation | SimulationHom | SimulationProductOutput | IOSimulationPhase | `cata-simulate` |
| Fabrication | FabricationHom | FabricationProductOutput | IOFabricationPhase | `cata-fabricate` |
| Verify | VerifyHom | VerifyProductOutput | IOVerifyPhase | `cata-verify` |
| Main | MainHom | MainProductOutput | IOMainPhase | `hylo-main` |

### 1-1 Observer Mapping

Every observer has exactly: CoHom + CoProductOutput + CoProductMeta + CoIO executor + justfile entry.

| Phase | CoHom | CoProductOutput | CoIO Executor | justfile |
|-------|-------|-----------------|---------------|----------|
| Discovery | CoDiscoveryHom | CoDiscoveryProductOutput | CoIODiscoveryPhase | `ana-discovery` |
| Ingest | CoIngestHom | CoIngestProductOutput | CoIOIngestPhase | `ana-ingest` |
| Geometry | CoGeometryHom | CoGeometryProductOutput | CoIOGeometryPhase | `ana-geometry` |
| Simulation | CoSimulationHom | CoSimulationProductOutput | CoIOSimulationPhase | `ana-simulation` |
| Fabrication | CoFabricationHom | CoFabricationProductOutput | CoIOFabricationPhase | `ana-fabrication` |
| Verify | CoVerifyHom | CoVerifyProductOutput | CoIOVerifyPhase | `ana-verify` |
| Main | CoMainHom | CoMainProductOutput | CoIOMainPhase | `ana-main` |

## Justfile Commands as Functors (6-Functor Formalism)

Every justfile command is a morphism classified by the 6-functor formalism:

| Prefix | Recursion Scheme | Direction | Maps to |
|--------|-----------------|-----------|---------|
| `ana-` | Anamorphism (unfold) | Observe / extract | CoTypes/ |
| `cata-` | Catamorphism (fold) | Produce / deploy | Types/ |
| `hylo-` | Hylomorphism (unfold+fold) | Composite | Types/ tensor CoTypes/ |

**Testing = coalgebraic observation.** Every `cata-*` has an `ana-*` dual. Validation is not a separate concern — it is the CoIO mapping of the IO executor.

## Import DAG (strictly layered)

```
Identity <- Inductive <- Dependent <- Hom <- Product
                                           ^
                                     Monad
                                           ^
                                      IO
```

No upward imports. Monad and IO are terminal — they may reference all lower layers.

## IO Executors (Types/IO/)

Every IO executor is a self-contained QGP-layer module with its own `BaseSettings` + `default.json` + `run()` + `__main__`. It reads typed config, calls external libraries, and writes artifacts. No IO executor defines types — all types live in `Types/`.

- **IODiscoveryPhase** — Phase 1 (BEC): catalog search, material database lookup
- **IOIngestPhase** — Phase 2 (Crystalline): CAD file import, mesh parsing, material spec parsing
- **IOGeometryPhase** — Phase 3 (Liquid Crystal): CadQuery parametric modeling, CSG operations
- **IOSimulationPhase** — Phase 4 (Liquid): sfepy FEA, thermal analysis, topology optimization
- **IOFabricationPhase** — Phase 5 (Gas): slicing, toolpath generation, G-code output
- **IOVerifyPhase** — Phase 6 (Plasma): dimensional analysis, tolerance checking, printability
- **IOMainPhase** — Phase 7 (QGP): full pipeline orchestration, deploy to printer/CNC

## Naming Invariants

- **All filenames must be `default.*`** — `default.py` for code, `default.json` for config. The only exception is `__init__.py`. No other filenames under `Types/` or `CoTypes/`.
- **All directory names must start with an uppercase letter** — `Types/Hom/Geometry/`, not `Types/Hom/geometry/`.
- `{Domain}Identity` — terminal/identity type [Identity]
- `{Domain}Inductive` — structural validation or sum type [Inductive]
- `{Domain}Dependent` — parameterized type [Dependent]
- `{Phase}Hom` — phase input type [Hom]
- `{Phase}ProductOutput` / `{Phase}ProductMeta` — phase output/meta [Product]
- `{Effect}Monad` — effect record type [Monad]
- `IO{Phase}Phase` — IO executor in `Types/IO/` [IO]
- `Co{Phase}Hom` — observation spec in `CoTypes/CoHom/` [CoHom]
- `Co{Phase}ProductOutput` / `Co{Phase}ProductMeta` — observation result [CoProduct]
- `CoIO{Phase}Phase` — observer executor in `CoTypes/IO/` [CoIO]

## Type Invariants

1. **<=7 fields per type** — >7 signals the type spans more than one symmetry group; decompose.
2. **Every field has `Field(description=...)`** — types are documentation.
3. **Every field bounded** — `ge=`/`le=` for numerics, `min_length=`/`max_length=` for strings. No unbounded types. No `Optional`/`None`. No `NaN`.
4. **Sentinel values for "not set"** — use `-1.0`, `-1`, `""` rather than `None`.
5. **Field Independence** — no field is derivable from another field on the same type.
6. **Field Completeness** — the field set spans the full degrees of freedom for this type's domain.
7. **Field Locality** — each field belongs to this phase's domain only; shared params move to `Identity/` or `Dependent/`.
8. **No named type aliases** — constraints live inline: `Annotated[str, StringConstraints(...)]` or `Field(ge=, le=)`.
9. **No cross-Hom imports** — shared types live in `Identity/`, `Inductive/`, or `Dependent/`.
10. **One type per `default.py`** — supporting enums acceptable in same file.
11. **Fully qualified imports** — `from Types.Identity.Design.default import DesignIdentity`. No wildcards.
12. **External data through Inductive types** — `MeshDataInductive.from_stl()`, etc. No raw dicts crossing IO boundary.
13. **Phases are symmetry groups** — directory encodes phase; class names use `{Domain}{PhaseType}` convention.
14. **Every function has typed IO** — all parameters and return types annotated. No exceptions.
15. **Meta extends Product symmetry group** — add Meta types, not Output fields, for more observables.
16. **Input sanitization via pydantic** — users cannot set values outside bounded fields.
17. **`default.json` is committed** — it is the IO boundary, equivalent to a lock file.
18. **Invariants are never traded away for convenience** — no exceptions to phase placement rules.
19. **Phase placement is determined solely by type theory** — semantic convenience never overrides this.
20. **All geometry via CadQuery** — no raw OpenCASCADE calls in Types/. CadQuery is the IO executor's tool.
21. **Units are SI** — meters, pascals, kelvin. No imperial units. No mixed unit systems.
22. **Hom/ has exactly 7 directories** — one per phase. Pipeline orchestration params live in `Dependent/Orchestration/`.
23. **IOMainPhase is the canonical pipeline entrypoint** — imports phases 1-6, orchestrates phase 7.

## Anti-Patterns

- Nested classes in `default.py` -> each type gets its own `default.py`
- Untyped function -> every function has typed parameters and return
- Wildcard or relative imports -> use fully qualified paths
- Unvalidated external data -> wrap in Inductive types
- Type suffix mismatch -> suffix must match phase (`{Domain}Identity`, `{Phase}Hom`, etc.)
- Named type alias at module scope -> inline constraints at the field
- `null` / `""` / `-1` as sentinel without documenting intent -> document in `Field(description=...)`
- Cross-Hom import -> shared type belongs in `Identity/`, `Inductive/`, or `Dependent/`
- 8th Hom directory (PipelineHom) -> orchestration params belong in `Dependent/`
- Validate directory in Types/IO/ -> all validation is coalgebraic, lives in CoTypes/
- Ad-hoc CoType names -> every CoType name is the Co-prefixed dual of its Types/ counterpart
- Raw OpenCASCADE in Types/ -> CadQuery is the IO-layer abstraction
- Imperial units -> SI only (meters, pascals, kelvin)
- Unprefixed justfile recipe -> classify as ana-/cata-/hylo-
- Using the word "config" -> it is a dependent type serving as the domain of a morphism

## Process Invariants

- **Docs first.** Update AGENTS.md and README.md before any code change.
- **Read before write.** Re-read docs before every update.
- **justfile is the only interface.** All phase execution goes through `just {prefix}-{phase}`. No raw `python -m` commands.
- **Git commits as you go.** Commit after each logical unit of work. One-liner format:

## Git Commit Convention

Commits are classified morphisms. Format:

```
[{Scope} | {Category}] v{M}.{m}.{p}: {description}
```

- **Scope:** `MaterialLab`, `Types`, `CoTypes`, `IO`, `CoIO`, `Hom`, `Product`, `Docs`
- **Category:** `Identity`, `Inductive`, `Dependent`, `Hom`, `Product`, `Monad`, `IO`, `CoIO`, `Refactor`, `Fix`, `Docs`
- **Version:** Major (phase chain change), Minor (new types/executors), Patch (fixes/docs)

Examples:

```
[MaterialLab | Docs] v0.1.0: 5 canonical docs, full Types/CoTypes scaffolding, Identity + Inductive types
[MaterialLab | Dependent] v0.2.0: Dependent + Monad types (11 default.py)
[MaterialLab | Hom] v0.3.0: all 7 Hom types + 14 Product types
[MaterialLab | IO] v0.4.0: IO executor stubs, all 7 default.py + default.json
[MaterialLab | CoIO] v0.5.0: full CoTypes scaffolding (CoHom, CoProduct, Comonad, CoIO)
```

## Toolchain

| Tool | Role |
|------|------|
| Python >= 3.12 | Runtime |
| pydantic >= 2.0 | Type system backbone |
| pydantic-settings >= 2.0 | IO executor settings (JSON + CLI) |
| CadQuery | Parametric CAD engine (OpenCASCADE) |
| sfepy | FEA simulation (pure Python) |
| trimesh | Mesh I/O, analysis, validation |
| uv | Dependency management |
| justfile | Morphism dispatcher — ana-/cata-/hylo- |
