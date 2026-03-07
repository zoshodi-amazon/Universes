# TRACKER.md

Implementation state for the MaterialLab universe. Single source of truth for what exists, what's stubbed, and what's planned.

Pattern Version: v0.5.0 | Type: CoIO (observation of progress)

---

## Types/ (Algebraic -- Production)

### Category 1: Identity (BEC -- Unit/top)

| File | Status | Contents |
|------|--------|----------|
| `Types/Identity/Design/default.py` | Done | DesignIdentity (6 fields) |
| `Types/Identity/Run/default.py` | Done | RunIdentity (5 fields) |
| `Types/Identity/Material/default.py` | Done | MaterialIdentity (6 fields) |

### Category 2: Inductive (Crystalline -- ADT/Sum)

| File | Status | Contents |
|------|--------|----------|
| `Types/Inductive/CadFormat/default.py` | Done | CadFormatInductive (step, stl, threemf, iges, obj) |
| `Types/Inductive/ManufMethod/default.py` | Done | ManufMethodInductive (fdm, sla, cnc, laser, injection) |
| `Types/Inductive/MaterialClass/default.py` | Done | MaterialClassInductive (pla, abs, petg, nylon, resin, metal, wood) |
| `Types/Inductive/MeshData/default.py` | Done | MeshDataInductive (6 fields + from_trimesh) |
| `Types/Inductive/LoadCase/default.py` | Done | LoadCaseInductive (static, dynamic, thermal, impact) |

### Category 3: Dependent (Liquid Crystal -- Indexed)

| File | Status | Contents |
|------|--------|----------|
| `Types/Dependent/PrintProfile/default.py` | Done | PrintProfileDependent (6 fields) |
| `Types/Dependent/MaterialSpec/default.py` | Done | MaterialSpecDependent (6 fields) |
| `Types/Dependent/ToleranceSpec/default.py` | Done | ToleranceSpecDependent (5 fields) |
| `Types/Dependent/SimConfig/default.py` | Done | SimConfigDependent (5 fields) |
| `Types/Dependent/MachineSpec/default.py` | Done | MachineSpecDependent (6 fields) |
| `Types/Dependent/Orchestration/default.py` | Done | OrchestrationDependent (5 fields) |

### Category 4: Hom (Liquid -- A -> B)

| Phase | File | Status |
|-------|------|--------|
| Discovery | `Types/Hom/Discovery/default.py` | Done (5 fields) |
| Ingest | `Types/Hom/Ingest/default.py` | Done (5 fields) |
| Geometry | `Types/Hom/Geometry/default.py` | Done (5 fields) |
| Simulation | `Types/Hom/Simulation/default.py` | Done (5 fields) |
| Fabrication | `Types/Hom/Fabrication/default.py` | Done (5 fields) |
| Verify | `Types/Hom/Verify/default.py` | Done (5 fields) |
| Main | `Types/Hom/Main/default.py` | Done (4 fields) |

### Category 5: Product (Gas -- AxB)

| Phase | Output | Meta |
|-------|--------|------|
| Discovery | Done (5 fields) | Done (4 fields) |
| Ingest | Done (6 fields) | Done (4 fields) |
| Geometry | Done (6 fields) | Done (4 fields) |
| Simulation | Done (6 fields) | Done (4 fields) |
| Fabrication | Done (6 fields) | Done (4 fields) |
| Verify | Done (6 fields) | Done (4 fields) |
| Main | Done (6 fields) | Done (4 fields) |

### Category 6: Monad (Plasma -- M A)

| File | Status | Contents |
|------|--------|----------|
| `Types/Monad/Error/default.py` | Done | ErrorMonad (4 fields) + Severity + PhaseId |
| `Types/Monad/Metric/default.py` | Done | MetricMonad (4 fields) + MetricKind |
| `Types/Monad/Alarm/default.py` | Done | AlarmMonad (5 fields) |
| `Types/Monad/Observability/default.py` | Done | ObservabilityMonad (7 fields) |
| `Types/Monad/Store/default.py` | Done | StoreMonad (5 fields) |

### Category 7: IO (QGP -- Executors)

| Phase | default.py | default.json |
|-------|------------|-------------|
| IODiscoveryPhase | Stub (Settings + run raises NotImplementedError) | Done |
| IOIngestPhase | Stub | Done |
| IOGeometryPhase | Stub | Done |
| IOSimulationPhase | Stub | Done |
| IOFabricationPhase | Stub | Done |
| IOVerifyPhase | Stub | Done |
| IOMainPhase | Stub | Done |

---

## CoTypes/ (Coalgebraic -- Observation)

### CoHom (1-1 with Hom)

| Phase | File | Status |
|-------|------|--------|
| CoDiscovery | `CoTypes/CoHom/CoDiscovery/default.py` | Done (3 fields) |
| CoIngest | `CoTypes/CoHom/CoIngest/default.py` | Done (4 fields) |
| CoGeometry | `CoTypes/CoHom/CoGeometry/default.py` | Done (4 fields) |
| CoSimulation | `CoTypes/CoHom/CoSimulation/default.py` | Done (4 fields) |
| CoFabrication | `CoTypes/CoHom/CoFabrication/default.py` | Done (4 fields) |
| CoVerify | `CoTypes/CoHom/CoVerify/default.py` | Done (4 fields) |
| CoMain | `CoTypes/CoHom/CoMain/default.py` | Done (4 fields) |

### CoProduct (1-1 with Product)

| Phase | Output | Meta |
|-------|--------|------|
| CoDiscovery | Done (4 fields) | Done (3 fields) |
| CoIngest | Done (4 fields) | Done (3 fields) |
| CoGeometry | Done (4 fields) | Done (3 fields) |
| CoSimulation | Done (4 fields) | Done (3 fields) |
| CoFabrication | Done (4 fields) | Done (3 fields) |
| CoVerify | Done (4 fields) | Done (3 fields) |
| CoMain | Done (4 fields) | Done (3 fields) |

### Comonad

| File | Status | Contents |
|------|--------|----------|
| `CoTypes/Comonad/Trace/default.py` | Done | TraceComonad (5 fields) + CoPhaseId (7 variants) |

### CoIO Executors (1-1 with IO)

| Phase | CoIO Executor | default.json | Status |
|-------|--------------|-------------|--------|
| Discovery | `CoTypes/IO/CoIODiscoveryPhase/` | Done | Stub |
| Ingest | `CoTypes/IO/CoIOIngestPhase/` | Done | Stub |
| Geometry | `CoTypes/IO/CoIOGeometryPhase/` | Done | Stub |
| Simulation | `CoTypes/IO/CoIOSimulationPhase/` | Done | Stub |
| Fabrication | `CoTypes/IO/CoIOFabricationPhase/` | Done | Stub |
| Verify | `CoTypes/IO/CoIOVerifyPhase/` | Done | Stub |
| Main | `CoTypes/IO/CoIOMainPhase/` | Done | Stub |

---

## Infrastructure

| Component | Status |
|-----------|--------|
| `pyproject.toml` | Done |
| `.gitignore` | Done |
| `justfile` | Done (7 cata- + 7 ana- + 1 hylo-) |
| `__init__.py` stubs | Done (120 files) |
| `README.md` | Done |
| `AGENTS.md` | Done |
| `DICTIONARY.md` | Done |
| `TEMPLATE.md` | Done |
| `TRACKER.md` | Done (this file) |

---

## Type Counts

| Category | Types/ | CoTypes/ | 1-1? |
|----------|--------|----------|------|
| Identity | 3 | 3 (stubs) | Category-level |
| Inductive | 5 | 5 (stubs) | Category-level |
| Dependent | 6 | 6 (stubs) | Category-level |
| Hom | 7 | 7 | Phase-level |
| Product | 14 (7xOutput + 7xMeta) | 14 (7xOutput + 7xMeta) | Phase-level |
| Monad | 5 | 1 (Trace) | Category-level |
| IO | 7 | 7 | Phase-level |
| **Total** | **47** | **43** | All verified |

---

## Git History

| Commit | Description |
|--------|-------------|
| `[MaterialLab \| Docs] v0.1.0` | 5 canonical docs, full Types/CoTypes scaffolding, Identity + Inductive types |
| `[MaterialLab \| Dependent] v0.2.0` | Dependent types (6) + Monad types (5), git convention in AGENTS.md |
| `[MaterialLab \| Hom] v0.3.0` | all 7 Hom types + 14 Product types (7 Output + 7 Meta) |
| `[MaterialLab \| IO] v0.4.0` | IO executor stubs, all 7 default.py + default.json |
| `[MaterialLab \| CoIO] v0.5.0` | full CoTypes scaffolding — CoHom (7), CoProduct (14), Comonad (1), CoIO (7) |

---

## Next Steps (Priority Order)

1. **IOGeometryPhase implementation** -- CadQuery integration, first real executor
2. **Cyberdeck shell geometry** -- end-to-end test through Geometry phase
3. **IOIngestPhase implementation** -- STL/STEP parsing via trimesh
4. **IODiscoveryPhase implementation** -- local catalog search
5. **IOSimulationPhase implementation** -- sfepy FEA integration
6. **IOFabricationPhase implementation** -- slicer CLI integration
7. **IOVerifyPhase implementation** -- dimensional analysis
8. **IOMainPhase implementation** -- full pipeline orchestration
9. **CoIO observer implementations** -- all 7 observers
10. **Store integration** -- StoreMonad SQLite + blob filesystem
