# DICTIONARY.md

Formal glossary for the Universes repository. Every term used in AGENTS.md, README.md, and the codebase is defined here with its formal meaning, domain application, and directory mapping.

Pattern Version: v5.3.0 | Type: CoIO (observation)

---

## Algebra

**Formal:** A pair (A, f : F(A) → A) where F is an endofunctor. The structure map f *folds* F-shaped data into A.

**Domain:** Types/ is the algebraic side. Lean structures define how to *construct* phase data. IO executors fold Hom types into running system state.

**Directory:** `Types/` (all 7 categories)

## Coalgebra

**Formal:** A pair (A, g : A → F(A)) where F is an endofunctor. The structure map g *unfolds* A into F-shaped observations.

**Domain:** CoTypes/ is the coalgebraic side. Observation types define how to *destructure* running system state into typed evidence. The dual of every algebra.

**Directory:** `CoTypes/` (all 7 categories)

## Catamorphism

**Formal:** The unique algebra homomorphism from an initial algebra to any other algebra. Recursion scheme: fold. Consumes structure inward (leaves → root).

**Domain:** `cata-*` commands. Production operations that fold typed specifications into system state. `cata-build` folds types into a machine image. `cata-switch` folds types into a running home configuration.

**Prefix:** `cata-` (justfile)

## Anamorphism

**Formal:** The unique coalgebra homomorphism from any coalgebra to a terminal coalgebra. Recursion scheme: unfold. Generates structure outward (seed → leaves).

**Domain:** `ana-*` commands. Observation operations that unfold system state into typed evidence. `ana-check` unfolds flake integrity. `ana-{phase}` unfolds a running system into per-phase observations.

**Prefix:** `ana-` (justfile)

## Hylomorphism

**Formal:** Composition of an anamorphism followed by a catamorphism: `cata ∘ ana`. Unfold then fold. No intermediate data structure is materialized.

**Domain:** `hylo-*` commands. Composite operations: observe then produce. `hylo-main` = `ana-types-validate ⊗ cata-switch`. The event loop is a hylomorphism.

**Prefix:** `hylo-` (justfile)

## Profunctor

**Formal:** A bifunctor P : C^op × D → Set, contravariant in the first argument (inputs), covariant in the second (outputs).

**Domain:** Every phase is a profunctor. Hom/ is the contravariant leg (domain), Product/ is the covariant leg (codomain), and the IO executor is the effectful arrow between them.

**Pattern:** `Hom(phase) ──IO executor──▸ Product(phase)`

## Free Functor

**Formal:** Left adjoint F in the adjunction F ⊣ U. Takes a set and produces the free algebra — all possible expressions.

**Domain:** The production path (Types/ → IO → Product). Constructive and information-preserving. Given a Hom specification, the IO executor freely generates the complete system state. The construction history is retained in the type system.

## Forgetful Functor

**Formal:** Right adjoint U in the adjunction F ⊣ U. Takes an algebra and forgets its operations, yielding just the carrier set.

**Domain:** The observation path (Product → CoIO → CoProduct). Observational and information-losing. The observer sees the carrier (system state) but forgets the construction path. You can observe that GC is enabled, but not *how* it was enabled.

## Adjunction (Free-Forgetful)

**Formal:** F ⊣ U where F (free) is left adjoint to U (forgetful). The unit η : Id → U∘F and counit ε : F∘U → Id witness the adjunction.

**Domain:** The relationship between production and observation. η = toJson (serialize, preserves information). ε = fromJson (deserialize, reconstructs). Roundtrip closure (fromJson ∘ toJson = id) is the adjunction identity. The system is well-typed when what you build (F) is what you observe (U), modulo the forgotten construction path.

## Bidirectional Path Closure

**Formal:** Agreement between two observation paths to the same codomain. Path (a) destructures the typed output. Path (b) probes the live system. Both yield CoProduct. If they agree, the path is closed.

**Domain:** CoTypes/ is the bidirectional path closure witness. Path (a): `Hom → toJson → fromJson → Hom` (schema validation via `ana-types-validate`). Path (b): `[running system] → CoIO → CoProduct` (runtime validation via `ana-{phase}`). Agreement = correctness.

## Hom

**Formal:** The set of morphisms between two objects in a category. Hom(A, B) = all arrows from A to B.

**Domain:** `Types/Hom/` — phase input morphisms. Each `Hom/{Phase}/Default.lean` defines the domain of the profunctor for that phase. What was previously called "configuration."

**Directory:** `Types/Hom/`

## CoHom

**Formal:** The dual of Hom — destructors instead of constructors. Observation morphisms that decompose rather than compose.

**Domain:** `CoTypes/CoHom/` — observation specifications. Field-parallel to Hom/ but with observation types (Bool for "is this set?", Option for "what did we see?"). Defines *what to check* for each phase.

**Directory:** `CoTypes/CoHom/`

## Product

**Formal:** The categorical product A × B. The universal object with projections to both components.

**Domain:** `Types/Product/` — phase outputs. Each phase produces Output (what was built) + Meta (build metadata). The codomain of the profunctor.

**Directory:** `Types/Product/{Phase}/{Output,Meta}/`

## CoProduct

**Formal:** The categorical coproduct A + B. The dual of product — injections rather than projections.

**Domain:** `CoTypes/CoProduct/` — observation results. What the observer actually saw per phase. Populated by either path (a) or path (b). The codomain of the observation triad.

**Directory:** `CoTypes/CoProduct/`

## Identity (Type Category)

**Formal:** The terminal object ⊤ in a category. Exactly one morphism from every object to ⊤.

**Domain:** `Types/Identity/` — terminal objects with one canonical inhabitant. Package, ProgramConfig, Phase. Shared primitives referenced by all higher layers.

**Directory:** `Types/Identity/`

## CoIdentity

**Formal:** The coterminal (initial) object ⊥. The dual of the terminal object.

**Domain:** `CoTypes/CoIdentity/` — introspection witnesses. What can be observed about a terminal object: is the package installed? Is the key present? Is the nix daemon running?

**Directory:** `CoTypes/CoIdentity/`

## Inductive

**Formal:** An inductive type defined by its constructors. The free algebra of a polynomial endofunctor. Finite, exhaustible.

**Domain:** `Types/Inductive/` — ADTs / sum types. BootLoader, DisplayBackend, ShellEditor, etc. Every string-that-is-an-enum lives here.

**Directory:** `Types/Inductive/`

## CoInductive

**Formal:** A coinductive type defined by its destructors (observations). The cofree coalgebra. Potentially infinite, observed by elimination.

**Domain:** `CoTypes/CoInductive/` — elimination forms. Parsers, validators, exhaustiveness witnesses for each Inductive ADT. The observation interface: given a string, is it a valid constructor?

**Directory:** `CoTypes/CoInductive/`

## Dependent (Type Category)

**Formal:** A dependent type / indexed family. A type that depends on a value: B(a) for a : A. Fibered over the index.

**Domain:** `Types/Dependent/` — parameterized structures. NixSettings, BootConfig, NetworkConfig, etc. Indexed over Inductive variants (e.g., BootConfig depends on BootLoader choice).

**Directory:** `Types/Dependent/`

## CoDependent

**Formal:** Cofibration — the dual of fibration. The lifting property: given an observation, can it be lifted back to its fiber?

**Domain:** `CoTypes/CoDependent/` — schema conformance validators. Given a JSON blob and a platform index, does the observation inhabit the expected fiber? "Is this config valid for this platform?"

**Directory:** `CoTypes/CoDependent/`

## Monad

**Formal:** A monoid in the category of endofunctors. (M, return : A → M A, bind : M A → (A → M B) → M B). Sequences effectful computations.

**Domain:** `Types/Monad/` — effect types. PhaseError, BuildResult, SwitchResult, ValidationResult. The typed vocabulary for things that can go wrong (or right) during IO execution.

**Directory:** `Types/Monad/`

## Comonad

**Formal:** The dual of a monad. (W, extract : W A → A, extend : (W A → B) → W B). Contextual computations with history.

**Domain:** `CoTypes/Comonad/` — observation traces. `extract` gives the current observation. `extend` maps over the observation history. Tracks what was observed, when, and in what order.

**Directory:** `CoTypes/Comonad/`

## IO

**Formal:** The IO monad — computations that interact with the external world. Terminal in the effect hierarchy.

**Domain:** `Types/IO/` — IO executors (Nix scripts) and the Lake project root. The effectful profunctor arrows that *produce* system state from Hom types. Terminal in the import DAG.

**Directory:** `Types/IO/`

## CoIO

**Formal:** The dual of IO — observation executors. Computations that *read* from the external world without modifying it.

**Domain:** `CoTypes/CoIO/` — observer executors (Nix scripts) that probe system state and compare against CoHom expectations. Also: documentation files (.md) which observe without modifying.

**Directory:** `CoTypes/CoIO/`

## 6-Functor Formalism

**Formal:** Grothendieck's six operations on sheaves: f* ⊣ f* (pullback/pushforward), f! ⊣ f! (shriek), ⊗ ⊣ Hom (tensor/internal hom). Three adjoint pairs classifying all morphisms.

**Domain:** Every justfile recipe is classified by one of the six functors. `ana-*` uses f* (pullback), f! (shriek pullback), Hom (internal). `cata-*` uses f* (pushforward), f! (shriek push). `hylo-*` uses ⊗ (tensor product).

## Pullback (f*)

**Formal:** Inverse image functor. Pulls data back along a morphism f. Left adjoint of pushforward.

**Domain:** `ana-show`, `ana-eval`, `ana-{phase}` — pull back observable data from the system into typed evidence.

## Pushforward (f*)

**Formal:** Direct image functor. Pushes data forward along a morphism f. Right adjoint of pullback.

**Domain:** `cata-switch`, `cata-sync-to`, `cata-ssh` — push typed data forward into system state.

## Shriek (f!)

**Formal:** Proper pushforward / pullback with compact support. The "exceptional" adjoint pair — operations that may fail or have bounded extent.

**Domain:** `ana-check`, `ana-types-validate` (shriek pullback — validation that may fail). `cata-build`, `cata-gc`, `cata-optimize` (shriek push — production with side effects).

## Tensor (⊗)

**Formal:** The monoidal tensor product. A ⊗ B combines two objects in the monoidal category.

**Domain:** `hylo-*` commands. The tensor of observation and production: `ana-types-validate ⊗ cata-switch` = validate then deploy. The event loop.

## Terminal Object (⊤)

**Formal:** An object T such that for every object A there exists exactly one morphism A → T.

**Domain:** `Types/Identity/` types. `flake.lock`. Objects with exactly one canonical form — no degrees of freedom.

## Phase

**Formal:** A type-theoretic category applied to the device configuration domain. Each phase IS a category (not merely "belongs to" one).

**Domain:** The 7-phase chain: Identity (Unit) → Platform (ADT) → Network (Indexed) → Services (Hom) → User (Product) → Workspace (Monad) → Deploy (IO). Each phase name is domain-semantic; the type-theoretic identity is the invariant.

## Local Override (Fiber Bundle)

**Formal:** A section of a fiber bundle. The base space is `default.json` (Identity, committed). The fiber over a deployment site is `local.json` (Dependent, not committed). The IO executor computes the section by merging: `cfg = lib.recursiveUpdate base local`.

**Domain:** Machine-specific data (corporate hostnames, credentials, hardware details) lives in `local.json` files that are `.gitignore`'d. The committed `default.json` contains universal defaults. The IO executor takes the fiber bundle section (merge) and produces system state. This separates what a machine IS (universal type) from which specific machine (local observation).

**Pattern:** `default.json (Identity) ← lib.recursiveUpdate ← local.json (Dependent) → cfg (Product)`

## HardwareProfile

**Formal:** An inductive type (ADT) classifying hardware into finite profiles. Each constructor drives automatic configuration of kernel modules, drivers, and services.

**Domain:** `Types/Inductive/Default.lean` — `generic | laptop | desktop | server | vm`. The IO executor maps profiles to NixOS module configurations: laptop enables thermald, power management, fwupd; desktop enables GPU drivers, audio, bluetooth; vm uses minimal virtio modules.

**Directory:** `Types/Inductive/`
