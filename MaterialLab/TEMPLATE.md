# TEMPLATE.md

Canonical naming and structural template for the MaterialLab universe. Every name is a type. Every path is a type annotation. No ad-hoc naming. No exceptions.

Pattern Version: v0.1.0 | Type: CoIO (observation of naming invariants)

---

## 1. Universe Root

The repo root IS the type universe. Two top-level directories partition existence into dual halves:

```
MaterialLab/
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
| 6 | `Monad` | Monad (M A) | Plasma | Effects: errors, metrics, alarms, store |
| 7 | `IO` | IO | QGP | Executors: effectful profunctor arrows (Python + pydantic-settings) |

### CoTypes/ (Coalgebraic -- 1-1 dual)

| # | Directory Name | Type Theory | Dual Of | Role |
|---|----------------|-------------|---------|------|
| 1 | `CoIdentity` | Coterminal | Identity | Introspection witnesses: exists? present? valid? |
| 2 | `CoInductive` | Cofree | Inductive | Elimination forms: parsers, validators |
| 3 | `CoDependent` | Cofibration | Dependent | Lifting: schema conformance validators |
| 4 | `CoHom` | Destructors | Hom | Observation specs (field-parallel to Hom) |
| 5 | `CoProduct` | Coproduct | Product | Observation results: what was seen |
| 6 | `Comonad` | Comonad | Monad | Traces: extract (current) + extend (history) |
| 7 | `IO` | Observer | IO | Observer executors: probes, not producers |

**Naming rule:** Category names are PascalCase. CoTypes categories are prefixed with `Co` (not `co`). The sole exception is `Comonad` (standard mathematical spelling, not `CoMonad`). CoTypes observer executors live under `CoTypes/IO/` (not `CoTypes/CoIO/`).

---

## 3. The 7-Phase Chain (Domain Layer)

Phases are domain-specific applications of the 7 categories to material fabrication. The phase name is domain-semantic; the type-theoretic identity is the invariant.

```
Discovery -> Ingest -> Geometry -> Simulation -> Fabrication -> Verify -> Main
(Unit)       (ADT)     (Indexed)   (A -> B)      (AxB)          (M A)    (IO)
```

### Phase Names (FROZEN)

| # | Phase | Category | What It Produces |
|---|-------|----------|------------------|
| 1 | `Discovery` | Unit | Catalog search: existing designs, materials, part libraries |
| 2 | `Ingest` | Inductive | Import/parse: CAD files (STEP, STL, 3MF), material specs |
| 3 | `Geometry` | Dependent | Parametric modeling: CSG operations, mesh ops, CadQuery solids |
| 4 | `Simulation` | Hom | Analysis: FEA stress, thermal, topology optimization |
| 5 | `Fabrication` | Product | Manufacturing output: slicing, toolpaths, G-code |
| 6 | `Verify` | Monad | Conformance: dimensional analysis, tolerance checking, printability |
| 7 | `Main` | IO | Pipeline orchestration: full chain, deploy to printer/CNC |

**Naming rule:** Phase names are PascalCase in directories, lowercase in justfile commands. No sub-phases for MaterialLab v0.1.

---

## 4. Directory Path Templates

Directory paths ARE type annotations. The path encodes: which half (Types/CoTypes), which category, which phase, and which role.

### Types/ Paths

```
Types/Identity/{TypeName}/               -- Category 1: terminal objects
Types/Inductive/{TypeName}/              -- Category 2: ADT variants
Types/Dependent/{TypeName}/              -- Category 3: indexed structures
Types/Hom/{Phase}/                       -- Category 4: phase input morphisms (exactly 7)
Types/Product/{Phase}/Output/            -- Category 5: phase output
Types/Product/{Phase}/Meta/              -- Category 5: phase metadata
Types/Monad/{EffectName}/               -- Category 6: effect types
Types/IO/IO{Phase}Phase/                 -- Category 7: phase IO executor
```

### CoTypes/ Paths

```
CoTypes/CoIdentity/{CoTypeName}/         -- CoCategory 1: introspection witnesses
CoTypes/CoInductive/{CoTypeName}/        -- CoCategory 2: elimination forms
CoTypes/CoDependent/{CoTypeName}/        -- CoCategory 3: cofibration validators
CoTypes/CoHom/Co{Phase}/                 -- CoCategory 4: observation specifications
CoTypes/CoProduct/Co{Phase}/Output/      -- CoCategory 5: observation output
CoTypes/CoProduct/Co{Phase}/Meta/        -- CoCategory 5: observation metadata
CoTypes/Comonad/{TraceName}/             -- CoCategory 6: observation traces
CoTypes/IO/CoIO{Phase}Phase/             -- CoCategory 7: phase observer executor
```

### IO Executor Naming

IO executor directories follow the pattern `IO{Phase}Phase`:

| Phase | IO Executor Dir | CoIO Observer Dir |
|-------|----------------|-------------------|
| Discovery | `IODiscoveryPhase` | `CoIODiscoveryPhase` |
| Ingest | `IOIngestPhase` | `CoIOIngestPhase` |
| Geometry | `IOGeometryPhase` | `CoIOGeometryPhase` |
| Simulation | `IOSimulationPhase` | `CoIOSimulationPhase` |
| Fabrication | `IOFabricationPhase` | `CoIOFabricationPhase` |
| Verify | `IOVerifyPhase` | `CoIOVerifyPhase` |
| Main | `IOMainPhase` | `CoIOMainPhase` |

**Naming rule:** `IO` prefix, phase name in PascalCase, `Phase` suffix. Always. The `Co` variant prepends `Co` to the entire token: `CoIO{Phase}Phase`.

---

## 5. File Naming

### Python Files

Every Python type definition file is named `default.py`. Init files are `__init__.py`. No exceptions.

```
Types/{Category}/{TypeName}/default.py
Types/Hom/{Phase}/default.py
Types/Product/{Phase}/{Output,Meta}/default.py
Types/IO/IO{Phase}Phase/default.py
Types/IO/IO{Phase}Phase/default.json
CoTypes/{CoCategory}/{CoTypeName}/default.py
CoTypes/IO/CoIO{Phase}Phase/default.py
CoTypes/IO/CoIO{Phase}Phase/default.json
```

### Filetype Classification (FROZEN)

| Extension | Type Category | Rationale |
|-----------|--------------|-----------|
| `.py` | Determined by directory | Type definitions and IO executors |
| `.json` | IO boundary (`Types/IO/` or `CoTypes/IO/`) | Serialized Hom types at IO boundary |
| `.md` | CoIO / Comonad | Observation: describes without modifying |
| `.toml` | Dependent | Build parameterization: indexed over project |
| `.lock` | Identity | Terminal object: one canonical inhabitant |
| `.stl` | Product (artifact output) | Mesh artifact produced by Fabrication |
| `.step` | Product (artifact output) | Solid artifact produced by Geometry |
| `.gcode` | Product (artifact output) | Machine instructions produced by Fabrication |

---

## 6. Python Import Paths

Import paths mirror the filesystem exactly. Fully qualified, no wildcards:

```python
from Types.Identity.Design.default import DesignIdentity
from Types.Inductive.CadFormat.default import CadFormatInductive
from Types.Dependent.PrintProfile.default import PrintProfileDependent
from Types.Hom.Geometry.default import GeometryHom
from Types.Product.Geometry.Output.default import GeometryProductOutput
from Types.Product.Geometry.Meta.default import GeometryProductMeta
from Types.Monad.Error.default import ErrorMonad
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
CoTypes.CoDependent  <- Types.Dependent     (lifting needs fiber index)
CoTypes.CoHom        <- Types.Hom           (observation specs reference Hom fields)
CoTypes.CoProduct    <- Types.Product       (observation results reference Product)
CoTypes.Comonad      <- Types.Monad         (traces reference effect types)
CoTypes.IO           <- CoTypes.CoProduct   (observer results reference observations)
CoTypes.IO           <- CoTypes.Comonad     (observer results reference traces)
```

No upward imports. No cross-Hom imports. No IO executor imports another IO executor.

---

## 7. Python Type Naming

### Types/ Structures (pydantic BaseModel)

| Category | Pattern | Example |
|----------|---------|---------|
| Identity | `{Domain}Identity` | `DesignIdentity`, `RunIdentity`, `MaterialIdentity` |
| Inductive | `{Domain}Inductive` | `CadFormatInductive`, `MeshDataInductive` |
| Dependent | `{Domain}Dependent` | `PrintProfileDependent`, `SimConfigDependent` |
| Hom | `{Phase}Hom` | `DiscoveryHom`, `GeometryHom`, `SimulationHom` |
| Product Output | `{Phase}ProductOutput` | `GeometryProductOutput`, `FabricationProductOutput` |
| Product Meta | `{Phase}ProductMeta` | `GeometryProductMeta`, `FabricationProductMeta` |
| Monad | `{Effect}Monad` | `ErrorMonad`, `MetricMonad`, `ObservabilityMonad` |

### CoTypes/ Structures (pydantic BaseModel)

| CoCategory | Pattern | Example |
|------------|---------|---------|
| CoIdentity | `Co{Domain}Identity` | `CoDesignIdentity`, `CoRunIdentity` |
| CoInductive | `Co{Domain}Inductive` | `CoCadFormatInductive`, `CoMeshDataInductive` |
| CoDependent | `Co{Domain}Dependent` | `CoPrintProfileDependent`, `CoSimConfigDependent` |
| CoHom | `Co{Phase}Hom` | `CoDiscoveryHom`, `CoGeometryHom` |
| CoProduct Output | `Co{Phase}ProductOutput` | `CoGeometryProductOutput` |
| CoProduct Meta | `Co{Phase}ProductMeta` | `CoGeometryProductMeta` |
| Comonad | `TraceComonad` | `TraceComonad`, `CoPhaseId` |

### Field Naming Rules

- All fields are `snake_case` (Python convention)
- Boolean observation fields: `{thing}_observed`, `{thing}_valid`, `{thing}_present`
- Fields prefixed `io_` cross the IO boundary (external inputs/outputs)
- No bare `str` for finite variants: extract to `Types/Inductive/` as enum
- Every field has `Field(description=...)`
- Every field is bounded: `ge=`/`le=` for numerics, `min_length=`/`max_length=` for strings
- No `Optional`/`None` — sentinels (`-1.0`, `-1`, `""`) for "not set"
- Maximum 7 fields per type (blowup prevention)

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
| f* (pullback) | `ana-` | Pull back observable data | `ana-discovery`, `ana-geometry` |
| f! (shriek pullback) | `ana-` | Validation/observation that may fail | `ana-verify`, `ana-status` |
| Hom (internal) | `ana-` | List/enumerate structure | `ana-list` |
| f* (pushforward) | `cata-` | Push typed data into system | `cata-fabricate` |
| f! (shriek push) | `cata-` | Production with side effects | `cata-geometry`, `cata-simulate` |
| tensor (otimes) | `hylo-` | Composite: observe then produce | `hylo-main` |

### Command Naming Patterns

```
cata-discover                -- Produce: search catalogs, find designs/materials
cata-ingest                  -- Produce: import/parse CAD files + material specs
cata-geometry                -- Produce: parametric modeling, CSG operations
cata-simulate                -- Produce: FEA stress, thermal, topology optimization
cata-fabricate               -- Produce: slicing, toolpath generation, G-code
cata-verify                  -- Produce: dimensional analysis, tolerance checking

ana-discovery                -- Observe: catalog search results
ana-ingest                   -- Observe: parsed mesh/material data integrity
ana-geometry                 -- Observe: 3D geometry, CSG tree, parametric state
ana-simulation               -- Observe: stress/thermal fields, convergence
ana-fabrication              -- Observe: toolpaths, layer slices, G-code paths
ana-verify                   -- Observe: tolerance conformance, dimensional deviation
ana-main                     -- Observe: pipeline status, provenance, structural integrity

hylo-main {design}           -- Full pipeline: observe + produce (the event loop)
```

**Naming rule:** All lowercase, kebab-case. Phase names in commands are lowercase (not PascalCase). No unprefixed commands except `default`. Every `cata-*` has an `ana-*` dual.

---

## 9. Root-Level File Classification

Every file at the repo root has a type-theoretic classification:

| File | Type Category | Rationale |
|------|--------------|-----------|
| `justfile` | IO / CoIO | Dispatcher: each recipe is a classified morphism |
| `pyproject.toml` | Dependent | Build parameterization: indexed over project |
| `uv.lock` | Identity | Terminal object: one canonical inhabitant |
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

| Scope | When |
|-------|------|
| `Types` | Changes to Types/ only |
| `CoTypes` | Changes to CoTypes/ only |
| `Types \| CoTypes` | Changes spanning both |
| `IO` | Changes to Types/IO/ executors only |
| `CoIO` | Changes to CoTypes/IO/ observers only |
| `Hom` | Changes to Types/Hom/ only |
| `Product` | Changes to Types/Product/ only |
| `Docs` | Documentation-only changes (CoIO observation) |

### Category (TYPE of change)

| Category | Type Theory | When |
|----------|-------------|------|
| `Identity` | Terminal (new canonical form) | New lockfile, new pinned version |
| `Inductive` | ADT (new variant) | New enum, new sum type |
| `Dependent` | Indexed (parameterized) | New/changed indexed structure |
| `Hom` | Morphism (new arrow) | New phase input type |
| `Product` | Output (new result) | New phase output/meta |
| `Monad` | Effect (new side effect) | New error type, new result type |
| `IO` | Executor (new effect) | New/changed Python executor |
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
[Docs | CoIO] v0.1.0: 5 canonical docs, MaterialLab domain boundary
[Types | IO] v0.2.0: Identity + Inductive + Dependent types, IO executor stubs
[Types | CoTypes] v0.3.0: full Types/ + CoTypes/ scaffolding, all 7 phases
[IO | Hom] v0.4.0: IOGeometryPhase CadQuery integration, cyberdeck shell test
```

---

## 11. The Profunctor Pattern (per phase)

Every phase follows the same profunctor structure. This is the template for adding a new phase:

```
Types/Hom/{Phase}/default.py             -- Domain (input specification)
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom at IO boundary
Types/IO/IO{Phase}Phase/default.py       -- Arrow (effectful executor)
Types/Product/{Phase}/Output/default.py  -- Codomain output
Types/Product/{Phase}/Meta/default.py    -- Codomain metadata
```

Observation dual (1-1):

```
CoTypes/CoHom/Co{Phase}/default.py              -- What to check
CoTypes/IO/CoIO{Phase}Phase/default.py           -- How to check (probe)
CoTypes/IO/CoIO{Phase}Phase/default.json         -- Observer config at IO boundary
CoTypes/CoProduct/Co{Phase}/Output/default.py    -- What was seen (output)
CoTypes/CoProduct/Co{Phase}/Meta/default.py      -- What was seen (meta)
```

### Adding a New Phase (Checklist)

1. Name the phase (PascalCase, type-theoretically motivated)
2. Create `Types/Hom/{Phase}/default.py` with `{Phase}Hom` (BaseModel)
3. Create `Types/Product/{Phase}/Output/default.py` with `{Phase}ProductOutput`
4. Create `Types/Product/{Phase}/Meta/default.py` with `{Phase}ProductMeta`
5. Create `Types/IO/IO{Phase}Phase/default.py` (BaseSettings + run() + `__main__`)
6. Create `Types/IO/IO{Phase}Phase/default.json` (serialized Hom)
7. Add observation structures to CoTypes/ (CoHom, CoProduct, CoIO)
8. Add `cata-{phase}` and `ana-{phase}` commands in justfile
9. Update TRACKER.md

---

## 12. Domain-Specific Names: WHERE They Live

Domain-specific naming (vendor names, tool names, material names) is NOT scattered across the codebase. It is precisely placed:

| Domain Name Type | WHERE It Lives | Example |
|-----------------|----------------|---------|
| File format variants | `Types/Inductive/{TypeName}/default.py` | `step`, `stl`, `3mf`, `iges` |
| Manufacturing methods | `Types/Inductive/{TypeName}/default.py` | `fdm`, `sla`, `cnc`, `laser` |
| Material classes | `Types/Inductive/{TypeName}/default.py` | `pla`, `abs`, `petg`, `nylon` |
| Load case variants | `Types/Inductive/{TypeName}/default.py` | `static`, `dynamic`, `thermal` |
| Machine parameters | `Types/Dependent/{TypeName}/default.py` | `nozzle_dia`, `build_volume` |
| Print parameters | `Types/Dependent/{TypeName}/default.py` | `layer_height`, `infill_pct` |
| Phase input values | `Types/Hom/{Phase}/default.py` | `GeometryHom.operation` |
| Package names | `Types/IO/IO{Phase}Phase/default.py` | `cadquery`, `trimesh`, `sfepy` |
| Printer endpoints | `Types/IO/IOMainPhase/default.py` | OctoPrint URL |
| Deployment targets | `Types/Hom/Main/default.py` | printer name, CNC identifier |

**Naming rule:** Vendor/tool names NEVER appear in Types/ category or phase names. They appear ONLY as:
1. Inductive enum variants (e.g., `fdm | sla | cnc`)
2. Dependent structure fields (e.g., `nozzle_dia_mm`)
3. IO executor implementation details (library calls)

The type system is vendor-agnostic. The IO executors are vendor-specific.

---

## 13. Invariant Summary

1. Every name is a type. Directory placement IS typing.
2. 7 categories in Types/, 7 dual categories in CoTypes/. 1-1 correspondence.
3. Category names are PascalCase. Co-prefix for duals (except `Comonad`).
4. Phase names are PascalCase in directories, lowercase in justfile commands.
5. All Python type files are `default.py`. All init files are `__init__.py`. All JSON boundaries are `default.json`. No other filenames.
6. IO executors: `IO{Phase}Phase`. CoIO observers: `CoIO{Phase}Phase`.
7. Python types: `{Phase}Hom`, `{Phase}ProductOutput`, `{Phase}ProductMeta`, `Co{Phase}Hom`, `Co{Phase}ProductOutput`, `Co{Phase}ProductMeta`.
8. Justfile commands: `ana-` (observe), `cata-` (produce), `hylo-` (composite). No unprefixed commands.
9. Git commits: `[{Scope} | {Category}] v{M}.{m}.{p}: {description}`.
10. Domain-specific names live in Inductive (variants), Dependent (fields), and IO (implementations). Never in category or phase names.
11. Maximum 7 fields per type, 7 phases per module. No exceptions.
12. No `None`/`Optional`, no bare `str` for enums, no upward imports in the DAG.
13. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual. All validation lives in CoTypes/.
14. Names are first-class citizens. Every name carries type-theoretic weight. No ad-hoc naming. No exceptions.
15. IOMainPhase is the canonical pipeline entrypoint. It imports phases 1-6 and orchestrates phase 7.
16. Hom/ has exactly 7 directories — one per phase. No composition helpers. Pipeline orchestration parameters live in Dependent/.
