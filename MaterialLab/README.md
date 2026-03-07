# MATERIALLAB(7) - Typed Material Fabrication Pipeline

## NAME

MaterialLab - Typed phase pipeline for material fabrication. One operator x N manufacturing targets. Python types (7 categories) -> JSON -> Python IO executors.

## DOMAIN BOUNDARY

This Universe produces **physical material artifacts** -- 3D prints, CNC-machined parts, laser-cut assemblies, fabrication designs. The domain is closed around: one human operator x N manufacturing deployment targets. The end artifact is a complete, reproducible, type-checked design file deployable to a manufacturing endpoint.

**"Done"** = any design in the catalog can be produced by `hylo-main {design}` and fully observed at every stratum by `ana-{phase}`.

## SYNOPSIS

```
MaterialLab/
├── Types/                         # Python -- the type space (7 categories)
│   ├── Identity/                  # [BEC] Unit (top) -- terminal objects
│   ├── Inductive/                 # [Crystalline] ADT / Sum -- finite enums
│   ├── Dependent/                 # [Liquid Crystal] Indexed -- parameterized types
│   ├── Hom/                       # [Liquid] Function (A -> B) -- phase inputs
│   ├── Product/                   # [Gas] Product (AxB) -- phase outputs + meta
│   ├── Monad/                     # [Plasma] Monad (M A) -- effect types
│   └── IO/                        # [QGP] IO -- pydantic-settings executors
│       └── IO{Phase}Phase/        #   default.py + default.json per phase
├── CoTypes/                       # Coalgebraic dual of Types/ (1-1)
│   ├── CoIdentity/                # Terminal <-> Coterminal
│   ├── CoInductive/               # Free <-> Cofree
│   ├── CoDependent/               # Fibration <-> Cofibration
│   ├── CoHom/                     # Constructors <-> Destructors
│   ├── CoProduct/                 # Product <-> Coproduct
│   ├── Comonad/                   # Effects <-> Co-effects (traces)
│   └── IO/                        # Executors <-> Observers
│       └── CoIO{Phase}Phase/      #   default.py + default.json per observer
├── justfile                       # IO/CoIO dispatcher -- ana-/cata-/hylo-
├── pyproject.toml                 # Dependent -- build parameterization
├── AGENTS.md                      # CoIO -- invariant contract
├── README.md                      # CoIO -- system observation (this file)
├── DICTIONARY.md                  # CoIO -- formal glossary
├── TEMPLATE.md                    # CoIO -- naming specification
└── TRACKER.md                     # CoIO -- implementation state
```

**Pattern Version: v0.1.0**

## DESCRIPTION

Every phase is a profunctor: typed input (Hom) -> effectful arrow (IO executor) -> typed output (Product). The type system is pydantic BaseModel (runtime-checked, 7 type-theoretic categories). The IO boundary is JSON (default.json). The arrow layer is Python (pydantic-settings reading JSON + CLI overrides). The store is SQLite + blob filesystem -- the typed artifact store.

There are no "configurations" -- there are dependent types serving as domains of morphisms.

### Architecture

```
Types/ (pydantic)  ->  default.json  ->  Types/IO/ (pydantic-settings)
7-category DSL        IO boundary       IO executors (BaseSettings -> run())

CoTypes/ (pydantic) -- Coalgebraic dual of Types/ (1-1 correspondence)
```

### Phase Chain

```
Discovery -> Ingest -> Geometry -> Simulation -> Fabrication -> Verify -> Main
(Unit/top)   (ADT)     (Indexed)   (A -> B)      (AxB)          (M A)    (IO)
```

| # | Phase | Type Theory | Matter | Domain |
|---|-------|-------------|--------|--------|
| 1 | Discovery | Unit (top) | BEC | Catalog search, material databases, part libraries |
| 2 | Ingest | Inductive (ADT) | Crystalline | CAD file import (STEP/STL/3MF), material spec parsing |
| 3 | Geometry | Dependent (Indexed) | Liquid Crystal | CadQuery parametric modeling, CSG, mesh operations |
| 4 | Simulation | Hom (A -> B) | Liquid | sfepy FEA stress, thermal, topology optimization |
| 5 | Fabrication | Product (AxB) | Gas | Slicing, toolpath generation, G-code output |
| 6 | Verify | Monad (M A) | Plasma | Dimensional analysis, tolerance checking, printability |
| 7 | Main | IO | QGP | Full pipeline orchestration, deploy to printer/CNC |

### Profunctor Pattern

```
Hom(phase)  --IO executor--▸  Product(phase)
  (domain)    (default.py)       (codomain)
```

### Observation Pipeline (Coalgebraic Dual)

Production and observation are dual paths. CoTypes/ is the bidirectional path closure witness.

```
         Hom --IO--▸ Product
                        │
                   (a)  │  (b)
                        │
                        ▼
                    CoProduct
                        ▲
                        │
                  [produced artifact]
```

- Path (a): **Schema observation** -- `Hom -> to_json -> from_json -> Hom` roundtrip closure
- Path (b): **Runtime observation** -- `Product -> CoIO observer -> CoProduct` artifact probing
- Agreement between (a) and (b) = **bidirectional path closure** = system correctness

### Coalgebraic Dual (1-1)

| Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|--------|----------|---------|-------------------|
| `Identity/` | `CoIdentity/` | Terminal <-> Coterminal | Introspection witnesses (design exists? files present?) |
| `Inductive/` | `CoInductive/` | Free <-> Cofree | Elimination forms, mesh validators, format parsers |
| `Dependent/` | `CoDependent/` | Fibration <-> Cofibration | Schema conformance (profile valid for machine?) |
| `Hom/` | `CoHom/` | Constructors <-> Destructors | Observation specs (field-parallel to Hom/) |
| `Product/` | `CoProduct/` | Product <-> Coproduct | Observation results (what was seen per phase) |
| `Monad/` | `Comonad/` | Effects <-> Co-effects | Traces -- extract + extend over history |
| `IO/` | `IO/` | Executors <-> Observers | Observer executors -- probe artifacts |

## OPTIONS

Every justfile command is a classified morphism (6-functor formalism):

```
ana-{cmd}   -- anamorphism  -- coalgebraic observation (f*, f!, Hom)
cata-{cmd}  -- catamorphism -- algebraic production (f*, f!)
hylo-{cmd}  -- hylomorphism -- tensor composite: ana then cata (otimes)
```

### Catamorphisms (produce -> Types/)

```
cata-discover               # f! shriek push -- IODiscoveryPhase
cata-ingest                 # f! shriek push -- IOIngestPhase
cata-geometry               # f! shriek push -- IOGeometryPhase
cata-simulate               # f! shriek push -- IOSimulationPhase
cata-fabricate              # f! shriek push -- IOFabricationPhase
cata-verify                 # f! shriek push -- IOVerifyPhase
```

### Anamorphisms (observe -> CoTypes/)

```
ana-discovery               # f* pullback -- CoIODiscoveryPhase
ana-ingest                  # f* pullback -- CoIOIngestPhase
ana-geometry                # f* pullback -- CoIOGeometryPhase
ana-simulation              # f* pullback -- CoIOSimulationPhase
ana-fabrication              # f* pullback -- CoIOFabricationPhase
ana-verify                  # f* pullback -- CoIOVerifyPhase
ana-main                    # f* pullback -- CoIOMainPhase (status + validate)
```

### Hylomorphisms (unfold + fold -> Types/ otimes CoTypes/)

```
hylo-main {design}          # otimes tensor -- full pipeline: validate + produce + observe
```

## MANUFACTURING TARGETS

| Target | Method | Format | cata- | ana- |
|--------|--------|--------|-------|------|
| FDM Printer (e.g. Prusa MK4) | fdm | G-code | `hylo-main {design}` | `ana-{phase}` |
| SLA Printer | sla | Sliced layers | `hylo-main {design}` | `ana-{phase}` |
| CNC Mill | cnc | G-code / toolpath | `hylo-main {design}` | `ana-{phase}` |
| Laser Cutter | laser | SVG / DXF | `hylo-main {design}` | `ana-{phase}` |
| Export Only | file | STEP / STL / 3MF | `cata-geometry` | `ana-geometry` |

## CAVEATS

See AGENTS.md for full invariant list. Key constraints:

1. Directory placement IS typing. The path is the type annotation. No exceptions.
2. Every `just` command is a classified morphism: `ana-`, `cata-`, or `hylo-`. No unprefixed commands.
3. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual.
4. CoTypes/ is the bidirectional path closure witness: schema test + runtime validation.
5. Hom/ has exactly 7 directories -- one per phase. No PipelineHom. Orchestration params in Dependent/.
6. IOMainPhase is the canonical pipeline entrypoint.
7. All geometry via CadQuery. All simulation via sfepy. All units SI.
8. No bare `str` for finite variants. No `None`. No `Optional`.
9. Invariants are never traded away for convenience. No exceptions.
10. Docs first. Always.

## HISTORY

| Version | Date | Changes |
|---------|------|---------|
| v0.1.0 | 2026-03-06 | Initial domain boundary, 7-phase chain, 5 canonical docs, full Types/CoTypes structure |
