# Fab — Full-Spectrum Analysis Cyberdeck

Self-contained fabrication lab for designing, simulating, and building a portable full-spectrum analysis cyberdeck.

## Synopsis

```
just discover
just ingest
just geometry
just dynamics
just synthesis
just render
just serve
just pipeline
```

## Core Goal

- Full-spectrum analysis platform: RF/SDR, environmental, network, compute
- Portable, lightweight, reproducible — every build deterministic via Nix
- Plan-to-execution pipeline: design → simulate → validate → fabricate
- Domain-agnostic 7-phase cognitive pipeline applied to physical fabrication
- Eventually promotes: Labs (design) → Host (hardware config) → Fleet (deployment)

## Frozen Phase Chain

```
Discovery -> Ingest -> Geometry -> Dynamics -> Synthesis -> Render -> Serve
```

## Matter-Phase Type System

Types follow the free ⊣ forgetful adjunction, mapped to phases of matter:

| Phase | Layer | Description |
|-------|-------|-------------|
| **Solid** | UnitTypes | Irreducible basis vectors, maximally constrained, shared across ≥2 phases |
| **Liquid** | PhaseInputTypes | Bounded configs that flow into phases, structured but reshapable |
| **Gas** | PhaseOutputTypes | Computed artifacts, phase results expanding outward |
| **Plasma** | Monads/Settings | Free composition layer, IO boundary where types get composed from JSON/CLI |

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

## Architecture

```
Modules/Labs/Fab/
├── pyproject.toml
├── justfile
├── README.md
├── AGENTS.md
├── Types/
│   ├── UnitTypes/           # [Solid] Irreducible representations (basis vectors)
│   │   ├── FieldUnit/
│   │   ├── RunUnit/
│   │   ├── MaterialUnit/
│   │   ├── ComponentUnit/
│   │   ├── MeshUnit/
│   │   ├── BoardUnit/
│   │   └── SpectrumUnit/
│   ├── PhaseInputTypes/     # [Liquid] Phase input configs
│   │   ├── DiscoveryInput/
│   │   ├── IngestInput/
│   │   ├── GeometryInput/
│   │   ├── DynamicsInput/
│   │   ├── SynthesisInput/
│   │   ├── RenderInput/
│   │   ├── ServeInput/
│   │   └── PipelineInput/
│   └── PhaseOutputTypes/    # [Gas] Phase output artifacts
│       ├── DiscoveryOutput/
│       ├── IngestOutput/
│       ├── GeometryOutput/
│       ├── DynamicsOutput/
│       ├── SynthesisOutput/
│       ├── RenderOutput/
│       ├── ServeOutput/
│       └── PipelineOutput/
├── Env/
│   ├── Inputs/              # [Free] Ephemeral runtime reads (ReaderIO)
│   │   ├── cache/           # Downloaded datasheets, material DBs
│   │   └── .env             # API keys, service credentials (gitignored)
│   └── Outputs/             # [Forgetful] Persisted phase artifacts (WriterIO)
│       ├── logs/            # Phase execution logs
│       ├── render_logs/     # 3D renders, simulation visualizations
│       └── docs/
│           ├── arch/
│           └── tracker/
└── Monads/                  # [Plasma] IO phase type constructors (each with own BaseSettings + default.json)
    ├── IODiscoveryPhase/
    ├── IOIngestPhase/
    ├── IOGeometryPhase/
    ├── IODynamicsPhase/
    ├── IOSynthesisPhase/
    ├── IORenderPhase/
    ├── IOServePhase/
    └── IOPipelinePhase/
```

## Frozen UnitTypes

| Unit | Fields (≤7) | Role |
|------|-------------|------|
| FieldUnit | RunId, PartId, FilePath, DirPath, ISODate | IDs, paths, timestamps |
| RunUnit | run_id, run_ts, seed, name, output_dir, status, verbose | Run context |
| MaterialUnit | TBD — physical material properties | Shared material tensor |
| ComponentUnit | TBD — electronic component specs | Shared component specs |
| MeshUnit | TBD — 3D geometry metadata | Shared mesh descriptors |
| BoardUnit | TBD — PCB metadata | Shared board specs |
| SpectrumUnit | TBD — RF/SDR parameters | Shared spectrum params |

UnitType fields to be frozen after cyberdeck design invariants are specified.

## Phase Descriptions

| Phase | What it does |
|-------|-------------|
| Discovery | Scan component/material databases, enumerate design constraints, output typed manifest |
| Ingest | Pull datasheets + material specs, normalize to typed format in Env/Outputs/ |
| Geometry | Parametric CAD (CadQuery), mesh generation, manifold validation, print orientation |
| Dynamics | FEA thermal/structural, RF simulation, tolerance Monte Carlo, material compatibility |
| Synthesis | Cross-domain overlay, conflict detection, firmware config generation from component manifest |
| Render | 3D visualization with sim overlays, G-code slicing, firmware compile, BOM generation |
| Serve | Dashboard (static + live), interactive 3D, firmware flash, print monitor — main event loop |
| Pipeline | Orchestrator: Discovery→...→Render, parameter sweeps over design space |

## Type Invariants

- ≤7 params per typed object; >7 signals split
- Every field has `Field(description=...)`. Types are documentation.
- Output fields must be orthogonal. No field derivable from other fields on the same Output.
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

## Dependencies

```
cadquery, build123d, trimesh, numpy, pydantic, pydantic-settings,
matplotlib, pandas
```

Additional deps TBD after cyberdeck invariants are specified (KiCad bindings, FEniCS, GNURadio, ESP-IDF, etc.).
