# DICTIONARY.md

Formal glossary for the Universes monorepo. Every type-theoretic term used across labs is defined here with its formal meaning, domain application, and directory mapping.

This document also serves as the **comprehensive Rosetta stone** mapping CS/DevOps/infrastructure concepts to their type-theoretic and geometric groundings. If a concept appears in the system, it has an entry here. If it does not have an entry here, it is not yet understood well enough to enter the system.

Lab-specific DICTIONARY.md files extend this document with domain-specific terms.

---

## The Stratified Information Gradient

The 7 type-theoretic categories are not an arbitrary partition. They form a **monotonically increasing information gradient** -- a hierarchy of symmetry-breaking strata where each level has strictly more degrees of freedom than the one below. This is the same structure as phase transitions in condensed matter physics, and it serves the same purpose: organizing a continuum of complexity into discrete, cognitively navigable layers.

| # | Matter Phase | Symmetry Group | Degrees of Freedom | Type Theory | What Lives Here |
|---|-------------|----------------|-------------------|-------------|-----------------|
| 1 | BEC | Trivial {e} | 0 | Unit (terminal) | Frozen canonical forms. One inhabitant. No choice. |
| 2 | Crystalline | Space group | Finite discrete | Inductive (ADT) | Discrete enumerated variants. Finite, exhaustible. |
| 3 | Liquid Crystal | Partial SO(3) | Indexed continuous | Dependent (fibered) | Structures parameterized over discrete choices. Partial freedom. |
| 4 | Liquid | SO(3) | Continuous | Hom (A -> B) | Morphisms. Full rotational freedom. Inputs flow into outputs. |
| 5 | Gas | E(3) | Expanding | Product (A x B) | Outputs proliferate. Translations + rotations. Results expand outward. |
| 6 | Plasma | Gauge | Charged | Monad (M A) | Effects carry side-channel information. Ionized -- structure and charge separate. |
| 7 | QGP | Deconfined | Maximal | IO | Full interaction with external world. All internal structure dissolved into the environment. |

**The gradient is monotonic.** Information content (degrees of freedom) increases strictly from stratum 1 to stratum 7. Identity types have zero degrees of freedom (one canonical form). IO types have maximal degrees of freedom (arbitrary interaction with the external world). Every intermediate layer occupies a precise position in this gradient.

**The naming is cognitive optimization.** When you see "Crystalline," you immediately know: discrete, finite, enumerable, rigid structure. When you see "Liquid," you know: continuous, flowing, morphic. When you see "Plasma," you know: charged, effectful, side-channel information present. The geometric intuition is load-bearing -- it is how you navigate the system without consulting a lookup table.

**The symmetry groups are the formal backbone.** The progression trivial -> space group -> partial SO(3) -> SO(3) -> E(3) -> gauge -> deconfined is a precise mathematical statement about what transformations each stratum is invariant under. This is not a metaphor. It is the same symmetry-breaking cascade that governs physical phase transitions, applied to information structure.

---

## CS/DevOps -> Type Theory Rosetta Stone

Every infrastructure, DevOps, and computer science pattern has a category-theoretic grounding. This section maps common CS concepts to their type-theoretic identity, the 6-functor formalism classification where applicable, and their geometric binding in the stratified information gradient.

### Deployment and Delivery

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| CI/CD pipeline | Hylomorphism (ana-validate then cata-deploy) | hylo- (tensor) | QGP -- the full deconfinement loop |
| Blue/green deployment | Coproduct with swap natural transformation | CoProduct + Hom | Gas -- two expanding states, one active |
| Canary deployment | Dependent coproduct indexed over traffic fraction | Dependent + CoProduct | Liquid Crystal -- partial symmetry breaking |
| Rolling update | Natural transformation between successive Product states | Product (nat. trans.) | Gas -- gradual expansion |
| Rollback | Retraction morphism (section of the deployment arrow) | Hom (retraction) | Liquid -- reversible flow |
| Immutable infrastructure | Terminal objects (Identity types, lock files) | Identity | BEC -- frozen, one canonical form |
| Infrastructure as Code | The filesystem IS the type system (Types/ + CoTypes/) | All categories | All phases -- the entire gradient |
| GitOps | Free-forgetful adjunction (commit = unit eta, deploy = counit epsilon) | IO + CoIO (adjunction) | QGP -- adjunction closure between production and observation |
| Zero-downtime deploy | Continuous natural transformation (no discontinuity in Product) | Product (continuous nat. trans.) | Gas -> Gas -- smooth transition |
| Artifact registry | Identity cache -- terminal objects indexed by version | Identity + Dependent | BEC -- each version is a frozen canonical form |

### Service Architecture

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Microservices | Product of profunctors (decomposed monolithic Hom) | Hom x Product (product of profunctors) | Liquid -> Gas -- decomposition into independent flows |
| Monolith | Single profunctor (Hom -> Product via one IO executor) | Hom -> Product (single profunctor) | Liquid -- one continuous flow |
| Service mesh | Natural transformation between profunctor arrows | Hom (natural transformation) | Liquid -- continuous mediation between flows |
| API gateway | Coproduct injection into a universal Hom (fan-in morphism) | Hom (coproduct injection) | Liquid -- convergent flow |
| Sidecar pattern | Product with auxiliary profunctor (A x B where B is the sidecar) | Product | Gas -- parallel expansion |
| Event-driven architecture | Coalgebraic stream processing (coinductive observation) | CoInductive + Comonad | Crystalline dual -- cofree stream of events |
| Message queue | Monad transformer (buffered effect sequencing) | Monad | Plasma -- charged messages in transit |
| CQRS | Algebra/coalgebra separation (Types/ for commands, CoTypes/ for queries) | Types/ vs CoTypes/ | The entire duality -- production vs observation |
| Pub/sub | Coproduct distribution (one publisher, N subscriber injections) | CoProduct (distribution) | Gas -- expanding to all subscribers |

### Data Patterns

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Caching | Memoized morphism (idempotent endofunctor on Hom) | Hom (idempotent endofunctor) | Liquid -- flow optimization, same input -> same output |
| Memoization | Idempotent endofunctor (f . f = f) | Hom (idempotent) | Liquid -- stable under re-application |
| Event sourcing | Cofree coalgebra (complete observation history) | Comonad (cofree) | Comonad traces -- extract current, extend over history |
| Eventual consistency | Coalgebraic convergence (observations converge to terminal coalgebra) | CoProduct (convergence) | Gas -> BEC -- expanding states settling to canonical form |
| ACID transactions | Monad laws (associativity + unit laws guarantee composition) | Monad (laws) | Plasma -- charged operations with guaranteed composition |
| Sharding | Dependent decomposition (data partitioned by index fiber) | Dependent | Liquid Crystal -- partitioned by discrete index |
| Replication | Product duplication (same data in multiple fibers) | Product (diagonal morphism) | Gas -- identical copies expanding |
| Database migration | Natural transformation between schema versions (Dependent -> Dependent) | Dependent (nat. trans.) | Liquid Crystal -> Liquid Crystal -- re-indexing |
| Schema evolution | Dependent type refinement (new fiber over extended index) | Dependent (refinement) | Liquid Crystal -- adding new partial symmetry |

### Resilience and Reliability

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Circuit breaker | Monad with short-circuit (Either/Result that stops propagation) | Monad (short-circuit) | Plasma -- fuse that breaks the charge flow |
| Retry with backoff | Anamorphic unfolding of attempt sequence (coalgebraic generation) | ana- (anamorphism) | CoInductive -- unfolding attempts until success or exhaustion |
| Bulkhead | Product isolation (independent failure domains as separate profunctors) | Product (isolation) | Gas -- independent compartments |
| Backpressure | Contravariant bound on Hom (rate-limiting the domain) | Hom (contravariant bound) | Liquid -- throttled flow |
| Graceful degradation | Coproduct fallback (primary + fallback injections) | CoProduct (fallback) | Gas -- multiple paths, select viable one |
| Health check | CoIO observer (probe artifact state without modifying) | ana- (f* pullback) | CoIO -- pure observation |
| Timeout | Monad with bounded effect (computation capped by time fiber) | Monad (bounded) | Plasma -- effect with finite lifetime |
| Idempotency | Idempotent morphism (f . f = f, applying twice = applying once) | Hom (idempotent) | Liquid -- stable under repetition |
| Dead letter queue | CoProduct error accumulator (failed messages observed coalgebraically) | CoProduct + Comonad | Gas + Comonad -- expanding error trace |

### Security

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Secrets management | Local override fiber bundle (local.json indexed over deployment site) | Dependent (fiber bundle) | Liquid Crystal -- site-indexed, never committed |
| TLS/mTLS | Authenticated channel monad (effect boundary with identity proof) | Monad (authenticated) | Plasma -- charged channel with identity |
| Zero trust | Every morphism requires proof of identity (no ambient authority) | Hom (dependent on Identity proof) | Liquid -- flow gated by BEC identity |
| RBAC | Dependent type indexed over role ADT (Inductive -> Dependent -> Hom) | Dependent (role-indexed) | Liquid Crystal -- permissions parameterized by role variant |
| Token rotation | Anamorphic generation of fresh Identity types (coalgebraic refresh) | ana- (Identity generation) | BEC -- refreshing the canonical form |
| Encryption at rest | Identity transformation (content-preserving, representation-changing) | Identity (isomorphism) | BEC -- same canonical form, different representation |
| Audit logging | Comonad trace (extract current event, extend over history) | Comonad | Comonad -- observation trace with full history |

### Observability

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Logging | Comonad trace emission (observation events written to stream) | Comonad (trace) | Comonad -- extract + extend over event history |
| Metrics | CoProduct numerical projections (scalar observations of system state) | ana- (f* pullback) | Gas dual -- numerical projections of expanding state |
| Distributed tracing | Comonad with span context (observation trace threaded through profunctors) | Comonad (contextual) | Comonad -- observation context propagated through morphisms |
| Alerting | CoIO shriek observer (observation that may trigger alarm = f! pullback) | ana- (f! shriek) | CoIO -- observation with failure/alarm channel |
| SLOs/SLAs | CoHom specification (what to check, expressed as observation bounds) | CoHom | CoHom -- observation specification with bounds |
| Dashboards | CoProduct rendering (observation results projected into visual form) | CoProduct (rendering) | Gas dual -- observation results made visible |

### Testing

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| A/B testing | Coproduct injection (two variants of a morphism, observed coalgebraically) | CoProduct (coproduct injection) | Gas -- two variants expanding, observed |
| Feature flags | Dependent type indexed over Bool fiber (enabled/disabled) | Dependent (Bool-indexed) | Liquid Crystal -- binary partial symmetry |
| Chaos engineering | Monad perturbation (inject failure effects, observe coalgebraically) | Monad + CoIO | Plasma -- perturb charge, observe result |
| Property-based testing | Universal quantification over Hom domain (for all inputs, property holds) | Hom (universal quantification) | Liquid -- for all flows, invariant holds |
| Integration testing | Coalgebraic observation of composed profunctors (ana- on Product) | ana- (composed observation) | CoIO -- observe the composed pipeline |
| E2E testing | Hylomorphism (full pipeline: produce then observe) | hylo- (tensor) | QGP -- full deconfinement: produce and observe everything |
| Unit testing | CoIdentity witness (terminal object observation: is it present? correct?) | ana- (CoIdentity) | BEC dual -- observe the frozen canonical form |
| Regression testing | Comonad history comparison (current observation vs. historical trace) | Comonad (history compare) | Comonad -- extend over history, compare |
| Snapshot testing | Identity comparison (current terminal object vs. committed terminal object) | Identity (equality) | BEC -- two frozen forms must be identical |

### Infrastructure

| CS Concept | Type-Theoretic Grounding | Category/Functor | Geometric Binding |
|-----------|-------------------------|-----------------|-------------------|
| Containers | Monad (isolated effect boundary with bind for composition) | Monad | Plasma -- contained charge, composable via bind |
| Virtual machines | Product of Identity (hardware) x Monad (OS effects) | Product + Monad | Gas + Plasma -- hardware x effects |
| Serverless | IO morphism with erased Identity (no persistent terminal object) | IO (erased Identity) | QGP -- fully deconfined, no persistent state |
| Edge computing | Dependent IO indexed over location (site-fibered executors) | IO + Dependent | QGP + Liquid Crystal -- IO indexed over site |
| CDN | Memoized Product cached at Dependent fiber points (location-indexed cache) | Product + Dependent (memoized) | Gas + Liquid Crystal -- cached expansions at indexed locations |
| DNS | Name resolution morphism (Inductive name -> Identity address) | Hom (Inductive -> Identity) | Liquid -- flow from discrete name to canonical address |
| Load balancer | Coproduct distribution morphism (fan-out over parallel profunctors) | Hom (coproduct distribution) | Liquid -> Gas -- single flow distributed to multiple outputs |
| Reverse proxy | Hom composition with Identity transformation (route + transform) | Hom (composition) | Liquid -- composed flow with routing |
| Orchestration | IOMainPhase -- imports phases 1-6, implements phase 7 | IO (terminal) | QGP -- the orchestrator is always at maximum deconfinement |
| Scheduling | Dependent monad (effects sequenced by time-indexed fiber) | Monad + Dependent | Plasma + Liquid Crystal -- effects indexed over time |

---

## Sheaf-Theoretic Foundations

The Type Universe has the structure of a sheaf over the space of artifact domains. This section defines the sheaf-theoretic vocabulary used to describe the relationship between the universal type system and its lab-specific instantiations.

---

### Sheaf

**Formal:** A presheaf F : Open(X)^op -> Set satisfying the gluing axiom: if local sections agree on overlaps, they glue to a unique global section.

**Domain:** The Type Universe F assigns to each artifact domain (open set U) its 7-stratum type system. Each lab is a local section s in F(U). The gluing axiom says: labs sharing Identity types (e.g., `Package`, `Version`) must assign them identical definitions. The universal invariants (AGENTS.md) are the restriction maps that all sections must satisfy.

### Section

**Formal:** An element s in F(U) -- a local assignment of data to an open set U, consistent with the sheaf structure.

**Domain:** A lab is a section of the Type Universe sheaf. Concretely, a lab is a 7-tuple (one type assignment per stratum) over a specific artifact domain, satisfying all universal invariants. Creating a new lab = choosing a domain U and specifying s in F(U).

### Stalk

**Formal:** F_x = colim_{U containing x} F(U) -- the colimit of all sections over open sets containing a point x.

**Domain:** The stalk at a specific domain x is all 7 strata instantiated for that domain. For SystemLab, the stalk is the complete set of types: Identity (Package, MachineConfig, ...) through IO (7 phase executors). The stalk is the "total type content" at a single domain point.

### Fiber

**Formal:** pi^{-1}(x) -- the preimage of a point x under a projection pi.

**Domain:** The fiber at a specific stratum for a specific lab. E.g., the fiber of SystemLab at stratum 2 (Inductive) is the set {BootLoader, Desktop, Gpu, ...}. Each stratum of each lab is one fiber of the total space.

### Restriction Map

**Formal:** rho_{V,U} : F(U) -> F(V) for V subset U -- the map that restricts a section from a larger open set to a smaller one.

**Domain:** The universal invariants (AGENTS.md, invariants 1-31) are the restriction maps. They constrain what a section can look like at any domain. Any lab section must satisfy all 31 invariants. The restriction maps are what make this a sheaf rather than a presheaf.

### Gluing Condition

**Formal:** If local sections s_i in F(U_i) agree on overlaps (s_i|_{U_i cap U_j} = s_j|_{U_i cap U_j}), they glue to a unique global section s in F(union U_i).

**Domain:** Labs sharing Identity types must agree. If SystemLab and HomeLab both reference `Package`, the definition must be identical (or factored into a shared sub-universe). The gluing condition ensures the monorepo is globally consistent, not just locally consistent per lab.

### Local-to-Global Principle

**Formal:** A sheaf is fully determined by its local data + gluing. Understanding the global object reduces to understanding each local section + how they agree on overlaps.

**Domain:** Understanding the Universes monorepo = understanding each lab's 7 sections + the universal invariants. There is no separate "global architecture" beyond the sheaf structure itself. The AGENTS.md invariants + each lab's AGENTS.md = the complete specification.

### Descent

**Formal:** A descent datum is a collection of local data + cocycle conditions that guarantee gluing to a global object. Effective descent = the glued object exists and is unique.

**Domain:** A well-formed lab (all 7 strata populated, all 31 invariants satisfied, all profunctor triads complete) is an effective descent datum. It "descends" to a valid section of the Type Universe sheaf. The completeness checklist in TEMPLATE.md Section 13 is the descent condition.

---

## Type-Theoretic Foundations

The formal definitions below ground every term used in the system. Each entry provides the category-theoretic definition, its domain application in the Universes system, and the directory where its instances live.

---

### Algebra

**Formal:** A pair (A, f : F(A) -> A) where F is an endofunctor. The structure map f *folds* F-shaped data into A.

**Domain:** Types/ is the algebraic side. Type definitions define how to *construct* phase data. IO executors fold Hom types into produced artifacts.

**Directory:** `Types/` (all 7 categories)

### Coalgebra

**Formal:** A pair (A, g : A -> F(A)) where F is an endofunctor. The structure map g *unfolds* A into F-shaped observations.

**Domain:** CoTypes/ is the coalgebraic side. Observation types define how to *destructure* produced artifacts into typed evidence. The dual of every algebra.

**Directory:** `CoTypes/` (all 7 categories)

### Catamorphism

**Formal:** The unique algebra homomorphism from an initial algebra to any other algebra. Recursion scheme: fold. Consumes structure inward (leaves -> root).

**Domain:** `cata-*` commands. Production operations that fold typed specifications into artifacts. `cata-build` folds types into a machine image. `cata-deploy` folds types into a deployed state.

**Prefix:** `cata-` (justfile)

### Anamorphism

**Formal:** The unique coalgebra homomorphism from any coalgebra to a terminal coalgebra. Recursion scheme: unfold. Generates structure outward (seed -> leaves).

**Domain:** `ana-*` commands. Observation operations that unfold artifact state into typed evidence. `ana-check` unfolds integrity. `ana-{phase}` unfolds into per-phase observations.

**Prefix:** `ana-` (justfile)

### Hylomorphism

**Formal:** Composition of an anamorphism followed by a catamorphism: `cata . ana`. Unfold then fold. No intermediate data structure is materialized.

**Domain:** `hylo-*` commands. Composite operations: observe then produce. `hylo-main` = validate then deploy. The event loop is a hylomorphism.

**Prefix:** `hylo-` (justfile)

### Profunctor

**Formal:** A bifunctor P : C^op x D -> Set, contravariant in the first argument (inputs), covariant in the second (outputs).

**Domain:** Every phase is a profunctor. Hom/ is the contravariant leg (domain), Product/ is the covariant leg (codomain), and the IO executor is the effectful arrow between them.

**Pattern:** `Hom(phase) --IO executor--> Product(phase)`

### Free Functor

**Formal:** Left adjoint F in the adjunction F -| U. Takes a set and produces the free algebra -- all possible expressions.

**Domain:** The production path (Types/ -> IO -> Product). Constructive and information-preserving. Given a Hom specification, the IO executor freely generates the complete artifact state. The construction history is retained in the type system.

### Forgetful Functor

**Formal:** Right adjoint U in the adjunction F -| U. Takes an algebra and forgets its operations, yielding just the carrier set.

**Domain:** The observation path (Product -> CoIO -> CoProduct). Observational and information-losing. The observer sees the carrier (artifact state) but forgets the construction path.

### Adjunction (Free-Forgetful)

**Formal:** F -| U where F (free) is left adjoint to U (forgetful). The unit n : Id -> U.F and counit e : F.U -> Id witness the adjunction.

**Domain:** The relationship between production and observation. n = toJson (serialize, preserves information). e = fromJson (deserialize, reconstructs). Roundtrip closure (fromJson . toJson = id) is the adjunction identity. The system is well-typed when what you build (F) is what you observe (U), modulo the forgotten construction path.

### Bidirectional Path Closure

**Formal:** Agreement between two observation paths to the same codomain. Path (a) destructures the typed output. Path (b) probes the live artifact. Both yield CoProduct. If they agree, the path is closed.

**Domain:** CoTypes/ is the bidirectional path closure witness. Path (a): schema validation (Hom -> toJson -> fromJson -> Hom roundtrip). Path (b): runtime validation (artifact -> CoIO -> CoProduct). Agreement = correctness.

### Hom

**Formal:** The set of morphisms between two objects in a category. Hom(A, B) = all arrows from A to B.

**Domain:** `Types/Hom/` -- phase input morphisms. Each `Hom/{Phase}/` defines the domain of the profunctor for that phase. What was previously called "configuration."

**Directory:** `Types/Hom/`

### CoHom

**Formal:** The dual of Hom -- destructors instead of constructors. Observation morphisms that decompose rather than compose.

**Domain:** `CoTypes/CoHom/` -- observation specifications. Field-parallel to Hom/ but with observation types (Bool for "is this set?", Option for "what did we see?"). Defines *what to check* for each phase.

**Directory:** `CoTypes/CoHom/`

### Product

**Formal:** The categorical product A x B. The universal object with projections to both components.

**Domain:** `Types/Product/` -- phase outputs. Each phase produces Output (what was built) + Meta (build metadata). The codomain of the profunctor.

**Directory:** `Types/Product/{Phase}/{Output,Meta}/`

### CoProduct

**Formal:** The categorical coproduct A + B. The dual of product -- injections rather than projections.

**Domain:** `CoTypes/CoProduct/` -- observation results. What the observer actually saw per phase. Populated by either path (a) or path (b). The codomain of the observation triad.

**Directory:** `CoTypes/CoProduct/`

### Identity (Type Category)

**Formal:** The terminal object top in a category. Exactly one morphism from every object to top.

**Domain:** `Types/Identity/` -- terminal objects with one canonical inhabitant. Shared primitives referenced by all higher layers.

**Directory:** `Types/Identity/`

### CoIdentity

**Formal:** The coterminal (initial) object. The dual of the terminal object.

**Domain:** `CoTypes/CoIdentity/` -- introspection witnesses. What can be observed about a terminal object: is it present? is it reachable? are its outputs valid?

**Directory:** `CoTypes/CoIdentity/`

### Inductive

**Formal:** An inductive type defined by its constructors. The free algebra of a polynomial endofunctor. Finite, exhaustible.

**Domain:** `Types/Inductive/` -- ADTs / sum types. Finite enumerations of variants. Every string-that-is-an-enum lives here.

**Directory:** `Types/Inductive/`

### CoInductive

**Formal:** A coinductive type defined by its destructors (observations). The cofree coalgebra. Potentially infinite, observed by elimination.

**Domain:** `CoTypes/CoInductive/` -- elimination forms. Parsers, validators, exhaustiveness witnesses for each Inductive ADT. The observation interface: given a value, is it a valid constructor?

**Directory:** `CoTypes/CoInductive/`

### Dependent (Type Category)

**Formal:** A dependent type / indexed family. A type that depends on a value: B(a) for a : A. Fibered over the index.

**Domain:** `Types/Dependent/` -- parameterized structures. Indexed over Inductive variants (e.g., a config depends on which variant was chosen).

**Directory:** `Types/Dependent/`

### CoDependent

**Formal:** Cofibration -- the dual of fibration. The lifting property: given an observation, can it be lifted back to its fiber?

**Domain:** `CoTypes/CoDependent/` -- schema conformance validators. Given a serialized blob and an index, does the observation inhabit the expected fiber?

**Directory:** `CoTypes/CoDependent/`

### Monad

**Formal:** A monoid in the category of endofunctors. (M, return : A -> M A, bind : M A -> (A -> M B) -> M B). Sequences effectful computations.

**Domain:** `Types/Monad/` -- effect types. Errors, build results, validation results. The typed vocabulary for things that can go wrong (or right) during IO execution.

**Directory:** `Types/Monad/`

### Comonad

**Formal:** The dual of a monad. (W, extract : W A -> A, extend : (W A -> B) -> W B). Contextual computations with history.

**Domain:** `CoTypes/Comonad/` -- observation traces. `extract` gives the current observation. `extend` maps over the observation history. Tracks what was observed, when, and in what order.

**Directory:** `CoTypes/Comonad/`

### IO

**Formal:** The IO monad -- computations that interact with the external world. Terminal in the effect hierarchy.

**Domain:** `Types/IO/` -- IO executors and (optionally) the build project root. The effectful profunctor arrows that *produce* artifact state from Hom types. Terminal in the import DAG.

**Directory:** `Types/IO/`

### CoIO

**Formal:** The dual of IO -- observation executors. Computations that *read* from the external world without modifying it.

**Domain:** `CoTypes/CoIO/` -- observer executors that probe artifact state and compare against CoHom expectations. Also: documentation files (.md) which observe without modifying.

**Directory:** `CoTypes/CoIO/`

### 6-Functor Formalism

**Formal:** Grothendieck's six operations on sheaves: f* -| f* (pullback/pushforward), f! -| f! (shriek), x -| Hom (tensor/internal hom). Three adjoint pairs classifying all morphisms.

**Domain:** Every justfile recipe is classified by one of the six functors. `ana-*` uses f* (pullback), f! (shriek pullback), Hom (internal). `cata-*` uses f* (pushforward), f! (shriek push). `hylo-*` uses x (tensor product).

### Pullback (f*)

**Formal:** Inverse image functor. Pulls data back along a morphism f. Left adjoint of pushforward.

**Domain:** `ana-*` commands that pull back observable data from the artifact into typed evidence.

### Pushforward (f*)

**Formal:** Direct image functor. Pushes data forward along a morphism f. Right adjoint of pullback.

**Domain:** `cata-*` commands that push typed data forward into artifact/system state.

### Shriek (f!)

**Formal:** Proper pushforward / pullback with compact support. The "exceptional" adjoint pair -- operations that may fail or have bounded extent.

**Domain:** `ana-*` commands that validate (shriek pullback -- may fail). `cata-*` commands that produce with side effects (shriek push).

### Tensor (x)

**Formal:** The monoidal tensor product. A x B combines two objects in the monoidal category.

**Domain:** `hylo-*` commands. The tensor of observation and production: validate then deploy. The event loop.

### Terminal Object (top)

**Formal:** An object T such that for every object A there exists exactly one morphism A -> T.

**Domain:** `Types/Identity/` types. Lock files. Objects with exactly one canonical form -- no degrees of freedom.

### Phase

**Formal:** A type-theoretic category applied to a specific artifact domain. Each phase IS a category (not merely "belongs to" one).

**Domain:** Every lab defines a 7-phase chain. Phase names are domain-semantic; the type-theoretic identity (Unit, ADT, Indexed, A->B, AxB, M A, IO) is the invariant that holds across all labs.

### Local Override (Fiber Bundle)

**Formal:** A section of a fiber bundle. The base space is `default.json` (Identity, committed). The fiber over a deployment site is `local.json` (Dependent, not committed). The IO executor computes the section by merging.

**Domain:** Site-specific data (credentials, hostnames, hardware details) lives in `local.json` files that are `.gitignore`'d. The committed `default.json` contains universal defaults. The IO executor takes the fiber bundle section (merge) and produces artifact state. This separates what a thing IS (universal type) from which specific instance (local observation).

**Pattern:** `default.json (Identity) <- merge <- local.json (Dependent) -> cfg (Product)`

### Projection Functor

**Formal:** A functor P : C -> D that maps objects and morphisms from a source category to a target category. Faithful if injective on Hom-sets.

**Domain:** The projection P : Lean_Types (strata 1-6) -> IO_Types (stratum 7) maps Lean type definitions to IO-layer language types via the JSON codec. P is faithful: every Lean type has a unique IO-layer projection. P is not full: IO-layer types may carry runtime-specific fields (e.g., Python method implementations) not present in the Lean source. The projection factors through JSON: `Lean --toJson--> JSON --fromJson (IO lang)--> IO-layer type`. Labs without Lean types yet carry provisional IO-layer types -- unfactored projections that must be replaced.

**Pattern:** `Lean type -> toJson -> default.json -> fromJson (IO lang) -> IO-layer type`

### Codec

**Formal:** An invertible encoding/decoding pair (encode : A -> B, decode : B -> A) where decode . encode = id. The unit and counit of the serialization adjunction.

**Domain:** The JSON codec (toJson, fromJson) mediates the Lean-IO boundary. `toJson` is the adjunction unit (eta): it serializes the Lean-typed Hom into `default.json`. `fromJson` (in the IO-layer language) is the adjunction counit (epsilon): it reconstructs the type from JSON. Roundtrip closure (`fromJson . toJson = id`) is the proof that the codec is well-typed. The codec is the witness to the Lean-IO adjunction -- it certifies that the IO-layer type is a faithful projection of the Lean type.

**Pattern:** `toJson (unit eta) -> default.json (boundary) -> fromJson (counit epsilon)`
