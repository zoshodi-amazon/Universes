# AGENTS.md -- Design Invariants

Rules for any agent (human or AI) working on this codebase.
**Read this file and README.md before every update.**

## Core Project Goal

Full-spectrum analysis cyberdeck fabrication lab:
- Portable, lightweight, reproducible — every build deterministic via Nix
- RF/SDR, environmental sensing, network analysis, compute
- Plan-to-execution: design → simulate → validate → fabricate
- Self-contained 7-phase cognitive pipeline
- Eventually promotes: Labs (design) → Host (hardware config) → Fleet (deployment)

## Process Invariants

- **Docs first.** Update AGENTS.md and README.md before any code change.
- **Read before write.** Re-read both docs before every update.

## Frozen Phase Chain

```
Discovery -> Ingest -> Geometry -> Dynamics -> Synthesis -> Render -> Serve
```

## 1:1 Phase Mapping

Every phase has exactly: Input + Output + Monad + justfile entry. No exceptions.

| Phase | Input | Output | Monad | justfile |
|-------|-------|--------|-------|----------|
| Discovery | DiscoveryInput | DiscoveryOutput | IODiscoveryPhase | `discover` |
| Ingest | IngestInput | IngestOutput | IOIngestPhase | `ingest` |
| Geometry | GeometryInput | GeometryOutput | IOGeometryPhase | `geometry` |
| Dynamics | DynamicsInput | DynamicsOutput | IODynamicsPhase | `dynamics` |
| Synthesis | SynthesisInput | SynthesisOutput | IOSynthesisPhase | `synthesis` |
| Render | RenderInput | RenderOutput | IORenderPhase | `render` |
| Serve | ServeInput | ServeOutput | IOServePhase | `serve` |
| Pipeline | PipelineInput | PipelineOutput | IOPipelinePhase | `pipeline` |

## Monads (1:1 with justfile)

Every monad is a self-contained IO phase with its own BaseSettings + default.json.

- **IODiscoveryPhase** -- standalone: scan component/material databases, enumerate constraints
- **IOIngestPhase** -- standalone: pull datasheets + material specs, normalize to typed format
- **IOGeometryPhase** -- standalone: parametric CAD, mesh generation, manifold validation
- **IODynamicsPhase** -- standalone: FEA thermal/structural, RF sim, tolerance Monte Carlo
- **IOSynthesisPhase** -- standalone: cross-domain overlay, conflict detection, firmware config gen
- **IORenderPhase** -- standalone: 3D visualization, G-code slicing, firmware compile, BOM
- **IOServePhase** -- standalone: dashboard + interactive 3D + firmware flash + print monitor
- **IOPipelinePhase** -- compound: Discovery → Ingest → Geometry → Dynamics → Synthesis → Render

## Per-Phase Settings

- Each `Monads/IO{X}Phase/` has its own `default.py` (BaseSettings + logic + `__main__`) and `default.json`
- Each phase is self-contained: reads its own JSON, accepts CLI overrides, no cross-phase imports for settings
- UnitTypes are the only shared types across phases
- No monolithic Config. No PhaseConfig wrapper.

## Matter-Phase Type System

Types follow the free ⊣ forgetful adjunction, mapped to phases of matter:

| Phase | Layer | Description |
|-------|-------|-------------|
| **Solid** | UnitTypes | Irreducible basis vectors, maximally constrained, shared across ≥2 phases |
| **Liquid** | PhaseInputTypes | Bounded configs that flow into phases, structured but reshapable |
| **Gas** | PhaseOutputTypes | Computed artifacts, phase results expanding outward |
| **Plasma** | Monads/Settings | Free composition layer, IO boundary where types get composed from JSON/CLI |

## Architectural Pattern

- **Types/UnitTypes/** -- [Solid] irreducible representations, basis vectors shared across >=2 phases (plain BaseModel)
- **Types/PhaseInputTypes/** -- [Liquid] phase input types (plain BaseModel)
- **Types/PhaseOutputTypes/** -- [Gas] phase output types (plain BaseModel)
- **Monads/** -- [Plasma] IO phase type constructors, each with own BaseSettings + default.json

## Naming Invariants

- `{X}Unit` -- irreducible shared type (basis vector) [Solid]
- `{X}Input` -- phase input type [Liquid]
- `{X}Output` -- phase output type [Gas]
- `IO{X}Phase` -- monad dir in Monads/ [Plasma]
- Every phase has exactly: Input type + Output type + Monad + justfile entry

## Frozen UnitTypes

| Unit | Fields (≤7) | Role |
|------|-------------|------|
| FieldUnit | RunId, PartId, FilePath, DirPath, ISODate | IDs, paths, timestamps |
| RunUnit | run_id, run_ts, seed, name, output_dir, status, verbose | Run context |
| MaterialUnit | TBD | Physical material properties |
| ComponentUnit | TBD | Electronic component specs |
| MeshUnit | TBD | 3D geometry metadata |
| BoardUnit | TBD | PCB metadata |
| SpectrumUnit | TBD | RF/SDR parameters |

UnitType fields to be frozen after cyberdeck design invariants are specified.

## Type Invariants

- ≤7 params per typed object; >7 signals split
- Every field has `Field(description=...)`. Types are documentation.
- **Output fields must be orthogonal.** No field derivable from other fields on the same Output.
- Every field bounded. No unbounded types. No Optional/None. No placeholders. No NaN.
- No misnomers. Semantic precision is the highest-priority invariant.
- No shared helper functions between Monads. Types enforce the contract.
- Env/ is a typed IO boundary. `Env/Inputs/` = ReaderIO. `Env/Outputs/` = WriterIO.
- No dropna. No emojis. No print in Monads. No ad-hoc overrides.
- No magic numbers in Monads. Config is single source of truth.
- No inline comments in Monads. Documentation lives in types and module docstrings.
- Every Monad run() wraps IO in try/except, returns typed ErrorUnit on failure.
- No unvalidated io_ path loads. Check file exists before read.
- `io_` prefix for external required inputs, `ValidationError` on missing.
- All imports at module top. No inline or deferred imports except `settings_customise_sources`.
- Docs first. Always.

## File Responsibilities

| Location | Does | Does NOT |
|----------|------|----------|
| `Types/` | Plain BaseModel type definitions with Field descriptions | Logic, pydantic-settings |
| `Monads/` | IO phase logic + BaseSettings + default.json | Define types |
| `Env/Inputs/` | Ephemeral runtime reads: cache, credentials, external data | Source code, persisted artifacts |
| `Env/Outputs/` | Persisted phase artifacts: meshes, sims, renders, firmware, docs | Source code, ephemeral data |

## Modification Rules

- **Docs first.** Always.
- To change a parameter: edit the phase's `default.json`.
- To change bounds: edit the typed BaseModel in Types/.
- To add a phase: add Input + Output in Types/, add IO{X}Phase in Monads/, update frozen tables.
- Every phase has exactly: Input + Output + Monad + justfile entry.
