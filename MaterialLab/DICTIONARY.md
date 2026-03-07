# DICTIONARY.md -- Domain Term Reference

Every domain-specific term in this codebase mapped to its type-theoretic phase,
matter state, directory location, and definition.

**Read this file when encountering an unfamiliar term. Update it when adding new terms.**

---

## Type-Theoretic Phases (Quick Reference)

| # | Phase | Type Theory | Matter | Directory | Suffix |
|---|-------|-------------|--------|-----------|--------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` | `{Domain}Identity` |
| 2 | Inductive | ADT / Sum | Crystalline | `Types/Inductive/` | `{Domain}Inductive` |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Phase}Hom` |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Phase}Product{Kind}` |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Effect}Monad` |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` |

CoTypes (dual):

| Phase | Directory | Suffix | Dual of |
|-------|-----------|--------|---------|
| CoHom | `CoTypes/CoHom/` | `Co{Phase}Hom` | Hom |
| CoProduct | `CoTypes/CoProduct/` | `Co{Phase}Product{Kind}` | Product |
| Comonad | `CoTypes/Comonad/` | `TraceComonad` | Monad |
| CoIO | `CoTypes/IO/` | `CoIO{Phase}Phase` | IO |

Pattern Version: v0.1.0 | Type: CoIO (observation)

---

## A -- Algebra and Architecture Terms

### Algebra

- **Formal:** A pair (A, f : F(A) -> A) where F is an endofunctor. The structure map f *folds* F-shaped data into A.
- **Domain:** Types/ is the algebraic side. Pydantic BaseModel structures define how to *construct* phase data. IO executors fold Hom types into manufactured artifacts.
- **Directory:** `Types/` (all 7 categories)

### Anamorphism

- **Formal:** The unique coalgebra homomorphism from any coalgebra to a terminal coalgebra. Recursion scheme: unfold.
- **Domain:** `ana-*` commands. Observation operations that unfold artifact state into typed evidence.
- **Prefix:** `ana-` (justfile)

### AlarmMonad

- **What:** Effect type for threshold-based alerts (dimensional deviation exceeds tolerance, print time exceeds estimate).
- **Where:** `Types/Monad/Alarm/default.py`
- **Phase:** Monad (Plasma)

---

## B -- BREP and Build Terms

### BREP (Boundary Representation)

- **What:** Solid modeling representation where shapes are defined by their bounding surfaces. CadQuery and OpenCASCADE use BREP internally.
- **Where:** Referenced in IOGeometryPhase implementation. Not a type -- an implementation detail.
- **Phase:** IO (QGP) -- lives in executor implementation

---

## C -- CAD and Category Terms

### CadFormatInductive

- **What:** Finite enum for CAD file formats: step, stl, 3mf, iges, obj. Determines which parser to invoke.
- **Where:** `Types/Inductive/CadFormat/default.py`
- **Phase:** Inductive (Crystalline)

### CadQuery

- **What:** Pure Python parametric CAD library built on OpenCASCADE. The canonical geometry engine for MaterialLab.
- **Where:** Used in IOGeometryPhase executor. Never imported in Types/ -- it is an IO-layer tool.
- **Invariant:** All geometry operations go through CadQuery. No raw OpenCASCADE calls.

### Catamorphism

- **Formal:** The unique algebra homomorphism from an initial algebra to any other algebra. Recursion scheme: fold.
- **Domain:** `cata-*` commands. Production operations that fold typed specifications into artifacts.
- **Prefix:** `cata-` (justfile)

### Coalgebra

- **Formal:** A pair (A, g : A -> F(A)) where F is an endofunctor. The structure map g *unfolds* A into F-shaped observations.
- **Domain:** CoTypes/ is the coalgebraic side. Observation types define how to *destructure* artifacts into typed evidence.
- **Directory:** `CoTypes/` (all 7 categories)

### CoPhaseId

- **What:** 7-variant enum identifying observer executors: discovery, ingest, geometry, simulation, fabrication, verify, main. Distinct from PhaseId.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad

### CSG (Constructive Solid Geometry)

- **What:** Method of creating complex solids by combining simpler ones using boolean operations: union, difference, intersection.
- **Where:** IOGeometryPhase executor (CadQuery CSG operations).
- **Phase:** IO (QGP)

---

## D -- Dependent and Design Terms

### default.json

- **What:** Committed JSON config file for each IO executor. The IO boundary -- equivalent to a lock file.
- **Where:** Every `Types/IO/IO{X}Phase/` and `CoTypes/IO/CoIO{X}Phase/` directory.
- **Invariant:** Must be faithful serialization of the Settings type.

### DesignIdentity

- **What:** Terminal object defining a single design: name, version, author, target manufacturing method, target material, source.
- **Where:** `Types/Identity/Design/default.py`
- **Phase:** Identity (BEC)

### DiscoveryHom

- **What:** Discovery phase input -- catalog sources, search filters, material constraints.
- **Where:** `Types/Hom/Discovery/default.py`
- **Phase:** Hom (Liquid)

---

## E -- Error and Effect Terms

### ErrorMonad

- **What:** Structured error record -- phase, severity, message, timestamp.
- **Where:** `Types/Monad/Error/default.py`
- **Phase:** Monad (Plasma)

---

## F -- Fabrication and FEA Terms

### FabricationHom

- **What:** Fabrication phase input -- slicer parameters, target machine, output format.
- **Where:** `Types/Hom/Fabrication/default.py`
- **Phase:** Hom (Liquid)

### FEA (Finite Element Analysis)

- **What:** Numerical method for predicting how objects behave under physical conditions (stress, heat, vibration). Discretizes geometry into mesh elements.
- **Where:** IOSimulationPhase executor (sfepy).
- **Phase:** IO (QGP)

---

## G -- Geometry and G-code Terms

### G-code

- **What:** Machine instruction language for CNC machines and 3D printers. Specifies tool movements, temperatures, speeds.
- **Where:** Product output of IOFabricationPhase. Observed by CoIOFabricationPhase.
- **Phase:** Product (Gas) as output artifact

### GD&T (Geometric Dimensioning and Tolerancing)

- **What:** System for defining and communicating engineering tolerances. Specifies allowable variation in form, profile, orientation, location, and runout.
- **Where:** Referenced in IOVerifyPhase for conformance checking. ToleranceSpecDependent holds tolerance values.
- **Phase:** Dependent (as spec), Monad (as verification effect)

### GeometryHom

- **What:** Geometry phase input -- parametric operations, dimensions, CSG tree, CadQuery script reference.
- **Where:** `Types/Hom/Geometry/default.py`
- **Phase:** Hom (Liquid)

---

## H -- Hom and Hylomorphism Terms

### Hom

- **What:** The set of morphisms between two objects. Phase input types -- what flows INTO a phase.
- **Where:** `Types/Hom/`
- **Instances:** DiscoveryHom, IngestHom, GeometryHom, SimulationHom, FabricationHom, VerifyHom, MainHom
- **Phase:** Liquid (state 4)

### Hylomorphism

- **Formal:** Composition of an anamorphism followed by a catamorphism: `cata . ana`.
- **Domain:** `hylo-*` commands. `hylo-main` = validate then produce then observe.
- **Prefix:** `hylo-` (justfile)

---

## I -- Identity and Ingest Terms

### Identity (type phase)

- **What:** Terminal objects with exactly one canonical inhabitant. Shared fixed points.
- **Where:** `Types/Identity/`
- **Instances:** DesignIdentity, RunIdentity, MaterialIdentity
- **Matter:** BEC -- coldest, most fundamental

### IngestHom

- **What:** Ingest phase input -- file paths, format hints, validation strictness.
- **Where:** `Types/Hom/Ingest/default.py`
- **Phase:** Hom (Liquid)

### io_ prefix

- **What:** Convention for fields that cross the IO boundary (external inputs/outputs). e.g., `io_name`, `io_source`, `io_file_path`.
- **Rule:** Fields prefixed `io_` are external-facing.

---

## L -- LoadCase Terms

### LoadCaseInductive

- **What:** Finite enum for simulation load cases: static, dynamic, thermal, impact.
- **Where:** `Types/Inductive/LoadCase/default.py`
- **Phase:** Inductive (Crystalline)

---

## M -- Material and Manufacturing Terms

### MachineSpecDependent

- **What:** Parameterized manufacturing machine specification -- build volume, nozzle diameter, resolution, max temp.
- **Where:** `Types/Dependent/MachineSpec/default.py`
- **Phase:** Dependent (Liquid Crystal)

### MainHom

- **What:** Main phase input -- pipeline orchestration parameters, deployment target.
- **Where:** `Types/Hom/Main/default.py`
- **Phase:** Hom (Liquid)

### ManufMethodInductive

- **What:** Finite enum for manufacturing methods: fdm, sla, cnc, laser, injection.
- **Where:** `Types/Inductive/ManufMethod/default.py`
- **Phase:** Inductive (Crystalline)

### MaterialClassInductive

- **What:** Finite enum for material classes: pla, abs, petg, nylon, resin, metal, wood.
- **Where:** `Types/Inductive/MaterialClass/default.py`
- **Phase:** Inductive (Crystalline)

### MaterialIdentity

- **What:** Terminal object defining a single material -- name, density, yield strength, thermal properties.
- **Where:** `Types/Identity/Material/default.py`
- **Phase:** Identity (BEC)

### MaterialSpecDependent

- **What:** Parameterized material property sheet -- tensile strength, thermal max, elongation, elastic modulus.
- **Where:** `Types/Dependent/MaterialSpec/default.py`
- **Phase:** Dependent (Liquid Crystal)

### MeshDataInductive

- **What:** Structural validation type for imported mesh data. Provides `from_stl()`, `from_step()` factory methods.
- **Where:** `Types/Inductive/MeshData/default.py`
- **Phase:** Inductive (Crystalline)
- **Invariant:** External mesh data always enters through this type. No raw dicts crossing IO boundary.

### MetricMonad

- **What:** Single metric observation point -- name, value, kind (counter or gauge).
- **Where:** `Types/Monad/Metric/default.py`
- **Phase:** Monad (Plasma)

---

## O -- Observability and Orchestration Terms

### ObservabilityMonad

- **What:** Free observability structure composed into every ProductMeta. Collects errors, metrics, alarms, timing.
- **Where:** `Types/Monad/Observability/default.py`
- **Phase:** Monad (Plasma)

### OrchestrationDependent

- **What:** Pipeline orchestration parameters -- sweep config, phase enable flags, target machine.
- **Where:** `Types/Dependent/Orchestration/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Note:** This is where pipeline composition params live (not in Hom/). IOMainPhase reads this.

---

## P -- Phase, Product, and Profunctor Terms

### Phase

- **Formal:** A type-theoretic category applied to the material fabrication domain. Each phase IS a category.
- **Domain:** The 7-phase chain: Discovery (Unit) -> Ingest (ADT) -> Geometry (Indexed) -> Simulation (Hom) -> Fabrication (Product) -> Verify (Monad) -> Main (IO).

### PhaseId

- **What:** 7-variant enum identifying pipeline phases: discovery, ingest, geometry, simulation, fabrication, verify, main.
- **Where:** `Types/Monad/Error/default.py`
- **Phase:** Monad (Plasma)

### PrintProfileDependent

- **What:** Parameterized print profile -- layer height, infill percentage, print speed, nozzle temp, bed temp.
- **Where:** `Types/Dependent/PrintProfile/default.py`
- **Phase:** Dependent (Liquid Crystal)

### Product (type phase)

- **What:** Phase outputs + meta. Computed results expanding outward from a phase.
- **Where:** `Types/Product/`
- **Structure:** `{Phase}/Output/default.py` + `{Phase}/Meta/default.py` for each of 7 phases.

### Profunctor

- **Formal:** A bifunctor P : C^op x D -> Set, contravariant in first (inputs), covariant in second (outputs).
- **Domain:** Every phase is a profunctor. Hom/ is the contravariant leg, Product/ is the covariant leg.

---

## R -- Run Terms

### RunIdentity

- **What:** Terminal object defining a single pipeline run -- run_id, timestamp, seed, store config.
- **Where:** `Types/Identity/Run/default.py`
- **Phase:** Identity (BEC)

### run_id

- **What:** 8-character hex string uniquely identifying a pipeline run.
- **Pattern:** `^[a-f0-9]{8}$`

---

## S -- Simulation and Store Terms

### sfepy

- **What:** Pure Python FEA library. Lightweight, code-native simulation engine for MaterialLab.
- **Where:** Used in IOSimulationPhase executor. Never imported in Types/.
- **Invariant:** All simulation goes through sfepy. Rendering of results is CoType business.

### SimConfigDependent

- **What:** Parameterized simulation configuration -- mesh density, solver type, max iterations, convergence threshold.
- **Where:** `Types/Dependent/SimConfig/default.py`
- **Phase:** Dependent (Liquid Crystal)

### SimulationHom

- **What:** Simulation phase input -- load conditions, material reference, boundary conditions.
- **Where:** `Types/Hom/Simulation/default.py`
- **Phase:** Hom (Liquid)

### StoreMonad

- **What:** Typed artifact store binding SQLite metadata to filesystem blobs. The IO boundary.
- **Where:** `Types/Monad/Store/default.py`
- **Phase:** Monad (Plasma)
- **Operations:** put(), get(), latest(), all_runs(), blob_path_for()

---

## T -- Tolerance and Trace Terms

### ToleranceSpecDependent

- **What:** Parameterized tolerance specification -- linear tolerance (mm), angular tolerance (deg), surface finish.
- **Where:** `Types/Dependent/ToleranceSpec/default.py`
- **Phase:** Dependent (Liquid Crystal)

### TraceComonad

- **What:** Coalgebraic observation cursor -- tracks where an observer is in the artifact/event stream.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad (dual of Monad)

### trimesh

- **What:** Python library for mesh I/O, analysis, and validation. Handles STL, OBJ, 3MF, PLY.
- **Where:** Used in IOIngestPhase (parsing) and IOVerifyPhase (dimensional analysis).

---

## V -- Verify Terms

### VerifyHom

- **What:** Verify phase input -- tolerance specs, reference geometry, check parameters.
- **Where:** `Types/Hom/Verify/default.py`
- **Phase:** Hom (Liquid)

### von Mises stress

- **What:** Scalar stress measure combining all stress tensor components. Used to predict yielding in ductile materials. If von Mises stress > yield strength, the part will deform.
- **Where:** SimulationProductOutput field. Observed by CoIOSimulationPhase.
- **Phase:** Product (Gas) as output, CoProduct as observation
