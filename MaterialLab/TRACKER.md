# TRACKER.md

Implementation state for the MaterialLab universe. Single source of truth for what exists, what's stubbed, and what's planned.

Pattern Version: v0.1.0 | Type: CoIO (observation of progress)

---

## Types/ (Algebraic -- Production)

### Category 1: Identity (BEC -- Unit/top)

| File | Status | Contents |
|------|--------|----------|
| `Types/Identity/Design/default.py` | Not started | DesignIdentity |
| `Types/Identity/Run/default.py` | Not started | RunIdentity |
| `Types/Identity/Material/default.py` | Not started | MaterialIdentity |

### Category 2: Inductive (Crystalline -- ADT/Sum)

| File | Status | Contents |
|------|--------|----------|
| `Types/Inductive/CadFormat/default.py` | Not started | CadFormatInductive (step, stl, 3mf, iges, obj) |
| `Types/Inductive/ManufMethod/default.py` | Not started | ManufMethodInductive (fdm, sla, cnc, laser, injection) |
| `Types/Inductive/MaterialClass/default.py` | Not started | MaterialClassInductive (pla, abs, petg, nylon, resin, metal, wood) |
| `Types/Inductive/MeshData/default.py` | Not started | MeshDataInductive (from_stl, from_step, validators) |
| `Types/Inductive/LoadCase/default.py` | Not started | LoadCaseInductive (static, dynamic, thermal, impact) |

### Category 3: Dependent (Liquid Crystal -- Indexed)

| File | Status | Contents |
|------|--------|----------|
| `Types/Dependent/PrintProfile/default.py` | Not started | PrintProfileDependent |
| `Types/Dependent/MaterialSpec/default.py` | Not started | MaterialSpecDependent |
| `Types/Dependent/ToleranceSpec/default.py` | Not started | ToleranceSpecDependent |
| `Types/Dependent/SimConfig/default.py` | Not started | SimConfigDependent |
| `Types/Dependent/MachineSpec/default.py` | Not started | MachineSpecDependent |
| `Types/Dependent/Orchestration/default.py` | Not started | OrchestrationDependent |

### Category 4: Hom (Liquid -- A -> B)

| Phase | File | Status |
|-------|------|--------|
| Discovery | `Types/Hom/Discovery/default.py` | Not started |
| Ingest | `Types/Hom/Ingest/default.py` | Not started |
| Geometry | `Types/Hom/Geometry/default.py` | Not started |
| Simulation | `Types/Hom/Simulation/default.py` | Not started |
| Fabrication | `Types/Hom/Fabrication/default.py` | Not started |
| Verify | `Types/Hom/Verify/default.py` | Not started |
| Main | `Types/Hom/Main/default.py` | Not started |

### Category 5: Product (Gas -- AxB)

| Phase | Output | Meta |
|-------|--------|------|
| Discovery | Not started | Not started |
| Ingest | Not started | Not started |
| Geometry | Not started | Not started |
| Simulation | Not started | Not started |
| Fabrication | Not started | Not started |
| Verify | Not started | Not started |
| Main | Not started | Not started |

### Category 6: Monad (Plasma -- M A)

| File | Status | Contents |
|------|--------|----------|
| `Types/Monad/Error/default.py` | Not started | ErrorMonad, Severity, PhaseId |
| `Types/Monad/Metric/default.py` | Not started | MetricMonad |
| `Types/Monad/Alarm/default.py` | Not started | AlarmMonad |
| `Types/Monad/Observability/default.py` | Not started | ObservabilityMonad |
| `Types/Monad/Store/default.py` | Not started | StoreMonad |

### Category 7: IO (QGP -- Executors)

| Phase | default.py | default.json |
|-------|------------|-------------|
| IODiscoveryPhase | Not started | Not started |
| IOIngestPhase | Not started | Not started |
| IOGeometryPhase | Not started | Not started |
| IOSimulationPhase | Not started | Not started |
| IOFabricationPhase | Not started | Not started |
| IOVerifyPhase | Not started | Not started |
| IOMainPhase | Not started | Not started |

---

## CoTypes/ (Coalgebraic -- Observation)

### Category-Level Duals

| # | Category | Directory | Status |
|---|----------|-----------|--------|
| 1 | CoIdentity | `CoTypes/CoIdentity/` | Not started |
| 2 | CoInductive | `CoTypes/CoInductive/` | Not started |
| 3 | CoDependent | `CoTypes/CoDependent/` | Not started |
| 4 | CoHom | `CoTypes/CoHom/` | Not started |
| 5 | CoProduct | `CoTypes/CoProduct/` | Not started |
| 6 | Comonad | `CoTypes/Comonad/` | Not started |
| 7 | CoIO | `CoTypes/IO/` | Not started |

### CoHom (1-1 with Hom)

| Phase | File | Status |
|-------|------|--------|
| CoDiscovery | `CoTypes/CoHom/CoDiscovery/default.py` | Not started |
| CoIngest | `CoTypes/CoHom/CoIngest/default.py` | Not started |
| CoGeometry | `CoTypes/CoHom/CoGeometry/default.py` | Not started |
| CoSimulation | `CoTypes/CoHom/CoSimulation/default.py` | Not started |
| CoFabrication | `CoTypes/CoHom/CoFabrication/default.py` | Not started |
| CoVerify | `CoTypes/CoHom/CoVerify/default.py` | Not started |
| CoMain | `CoTypes/CoHom/CoMain/default.py` | Not started |

### CoProduct (1-1 with Product)

| Phase | Output | Meta |
|-------|--------|------|
| CoDiscovery | Not started | Not started |
| CoIngest | Not started | Not started |
| CoGeometry | Not started | Not started |
| CoSimulation | Not started | Not started |
| CoFabrication | Not started | Not started |
| CoVerify | Not started | Not started |
| CoMain | Not started | Not started |

### Comonad

| File | Status | Contents |
|------|--------|----------|
| `CoTypes/Comonad/Trace/default.py` | Not started | TraceComonad, CoPhaseId |

### CoIO Executors (1-1 with IO)

| Phase | CoIO Executor | Status |
|-------|--------------|--------|
| Discovery | `CoTypes/IO/CoIODiscoveryPhase/` | Not started |
| Ingest | `CoTypes/IO/CoIOIngestPhase/` | Not started |
| Geometry | `CoTypes/IO/CoIOGeometryPhase/` | Not started |
| Simulation | `CoTypes/IO/CoIOSimulationPhase/` | Not started |
| Fabrication | `CoTypes/IO/CoIOFabricationPhase/` | Not started |
| Verify | `CoTypes/IO/CoIOVerifyPhase/` | Not started |
| Main | `CoTypes/IO/CoIOMainPhase/` | Not started |

---

## Infrastructure

| Component | Status |
|-----------|--------|
| `pyproject.toml` | Not started |
| `.gitignore` | Not started |
| `justfile` | Not started |
| `__init__.py` stubs | Not started |

---

## Manufacturing Targets

| Target | Method | Format | Producible? | Observable? |
|--------|--------|--------|------------|-------------|
| FDM Printer | fdm | G-code | Not started | Not started |
| SLA Printer | sla | Sliced layers | Not started | Not started |
| CNC Mill | cnc | G-code / toolpath | Not started | Not started |
| Laser Cutter | laser | SVG / DXF | Not started | Not started |
| Export Only | file | STEP / STL / 3MF | Not started | Not started |

---

## First Test Artifact

| Item | Status |
|------|--------|
| Cyberdeck shell design (DesignIdentity) | Not started |
| Geometry phase end-to-end (CadQuery CSG) | Not started |
| Full pipeline through Main | Not started |

---

## Next Steps (Priority Order)

1. **Project scaffolding** -- pyproject.toml, .gitignore, justfile, `__init__.py` stubs
2. **Identity + Inductive types** -- terminal objects and ADTs
3. **Dependent types** -- parameterized structures
4. **Monad types** -- effect types (reuse pattern from RL)
5. **Hom types** -- phase inputs (7 phases)
6. **Product types** -- phase outputs + meta (7 x {Output, Meta})
7. **IO executor stubs** -- BaseSettings + run() + `__main__` per phase
8. **CoTypes scaffolding** -- full 1-1 dual structure
9. **IOGeometryPhase** -- first real executor (CadQuery integration)
10. **Cyberdeck shell** -- end-to-end test through Geometry phase
