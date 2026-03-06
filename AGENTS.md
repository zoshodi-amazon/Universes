# AGENTS.md

Agent-optimized context for the Universes repository.

Pattern Version: v5.1.0 | Structure: FROZEN

## Domain Boundary

This Universe configures **devices**. The domain is closed around: one human operator × N hardware deployment targets (laptop, desktop, phone, cyberdeck, VM, cloud instance). The end artifact is a complete, reproducible, type-checked configuration for any device.

Sub-projects (RL trading, fabrication, sovereignty) are **separate Universes** with their own Types/CoTypes and domain-specific 7-phase chains. From this Universe's perspective they are Identity types (opaque packages consumed as devShell inputs).

**"Done"** = every target device in the deployment table can be produced by `cata-build {target}` and fully observed by `ana-{phase} {target}`.

## Architecture

```
Types/ (Lean 4)  →  default.json  →  Types/IO/ (Nix)
7-category DSL      IO boundary      IO executors (builtins.fromJSON → module API calls)

CoTypes/ (Lean 4) — Coalgebraic dual of Types/ (1-1 correspondence)
```

## Directory Placement IS Typing

Every file in the repository belongs to exactly one of 14 directories (7 Types + 7 CoTypes). The directory path IS the type annotation. Placing a file in `Types/Hom/Identity/` declares it as a morphism into the Identity phase. There is no separate type declaration — the filesystem is the type system.

If a file cannot be classified into exactly one of the 14 categories, either the file should not exist, or a category is missing.

## Filetype Classification

Every file extension maps to a type category:

| Extension | Category | Rationale |
|-----------|----------|-----------|
| `.lean` | Any (determined by directory) | Type definitions — the source of truth |
| `.nix` | IO (always `Types/IO/`) | Effect executors — the profunctor arrows |
| `.json` | IO boundary (`Types/IO/`) | Serialized Hom types at the IO boundary |
| `.py` | Any (determined by directory) | Parallel type system (Labs) |
| `.md` | CoIO / Comonad | Observation / documentation — describes without modifying |
| `.toml` | Dependent | Build parameterization — indexed over project identity |
| `.lock` | Identity | Terminal object — one canonical inhabitant |

Repo-root files:

| File | Type | Rationale |
|------|------|-----------|
| `flake.nix` | Hom (A → B) | The top-level morphism — maps inputs to flake outputs |
| `flake.lock` | Identity (⊤) | Terminal object — one canonical inhabitant per input set |
| `justfile` | IO / CoIO | Dispatcher — each recipe is a classified morphism |
| `AGENTS.md` | CoIO | Observation of the system (documentation) |
| `README.md` | CoIO | Observation of the system (documentation) |
| `DICTIONARY.md` | CoIO | Observation of the system (formal glossary) |
| `TRACKER.md` | CoIO | Observation of implementation state (progress) |
| `.gitignore` | Dependent | Parameterizes what the git IO executor observes |

## Phase Chain

```
Identity → Platform → Network → Services → User → Workspace → Deploy
(Unit/⊤)   (ADT)      (Indexed)  (A → B)    (A×B)  (M A)       (IO)
```

7 phases. Each phase IS a type-theoretic category applied to the device configuration domain. The phase name is domain-semantic; the type-theoretic identity is the invariant.

| # | Phase | Type Theory | Matter | Domain | Blowup Prevention |
|---|-------|-------------|--------|--------|-------------------|
| 1 | Identity | Unit (⊤) | BEC | Secrets, keys, Nix daemon, user account | Tight — 3-5 dependent types max |
| 2 | Platform | Inductive (ADT) | Crystalline | Boot, disk, hardware, display, peripherals | New hardware = new Inductive variant, not new Dependent type |
| 3 | Network | Dependent (Indexed) | Liquid Crystal | Firewall, SSH, wireless, VPN, DNS | Fiber bundle over platform — bounded by ≤7 fields |
| 4 | Services | Hom (A → B) | Liquid | Containers, daemons, databases | Thin for personal devices — full server admin is a different domain |
| 5 | User | Product (A × B) | Gas | Shell, terminal, editor, browser, CLI tools | **Shallow** — tool selections only, heavy configs are separate flakes consumed as Identity types |
| 6 | Workspace | Monad (M A) | Plasma | DevShells, language toolchains, build systems | **Shallow** — base toolchains only, per-project envs live in project repos |
| 7 | Deploy | IO | QGP | homeConfigurations, nixosConfigurations, ISOs, VMs | Bounded by finite deployment target list |

## Profunctor Pattern

Every phase is a profunctor: `Hom → Product` via an IO executor.

```
Hom(phase)  ──IO executor──▸  Product(phase)
  (domain)    (default.nix)      (codomain)
```

- `Hom/` types are the **domain** — bounded, normalized inputs (what was called "config")
- `Product/` types are the **codomain** — phase outputs + meta
- `Types/IO/IO{Phase}Phase/default.nix` is the **arrow** — the effectful profunctor implementation
- `default.json` is the **serialized Hom** at the IO boundary

There are no "configurations" — there are dependent types serving as domains of morphisms.

## Observation Pipeline (Coalgebraic Dual)

Production and observation are dual paths that must agree. The system has two observation modes:

### Path (a): Schema Observation (pure, type-level)

```
Hom(phase)  ──toJson──▸  default.json  ──fromJson──▸  Hom(phase)
              (unit η)                    (counit ε)
```

Roundtrip closure: `fromJson ∘ toJson = id`. The JSON boundary is the witness. This is `ana-types-validate`.

### Path (b): Runtime Observation (effectful, system-level)

```
Product(phase)  ──CoIO observer──▸  CoProduct(phase)
   (what was built)   (probe)          (what was seen)
```

The CoIO observer probes the live system and populates CoProduct — the observation result. This is `ana-{phase}`.

### Commutativity Invariant

Both paths must agree:

```
         Hom ──IO──▸ Product
                        │
                   (a)  │  (b)
                        │
                        ▼
                    CoProduct
                        ▲
                        │
                  [running system]
```

Path (a) destructures the typed output (Product → CoProduct). Path (b) probes the live system ([running system] → CoProduct). Agreement between (a) and (b) is the **bidirectional path closure** — the proof that the IO executor did what the types said it would.

- **Production** (Types/ → IO → Product) is the **free** direction — constructive, information-preserving.
- **Observation** (Product → CoIO → CoProduct) is the **forgetful** direction — observational, information-losing.
- The **free-forgetful adjunction** `F ⊣ U` between them is the formal statement that the system is well-typed: what you build is what you observe, modulo the forgotten construction path.

CoTypes/ is the **bidirectional path closure witness**: schema test + runtime validation. Both paths yield CoProduct. If they agree, the system is correct.

## CoTypes Observation Triad

Every phase has an observation triad (dual of the production profunctor):

```
CoHom(phase)  ──CoIO observer──▸  CoProduct(phase)
  (what to check)   (probe)         (what was seen)
```

- `CoHom/` types are the **observation specification** — what to check, field-parallel to Hom/
- `CoProduct/` types are the **observation result** — what was actually seen (Output + Meta)
- `CoTypes/CoIO/CoIO{Phase}Phase/` is the **observer executor** — the effectful probe
- CoHom mirrors Hom field-for-field but with observation types (Bool for "is this set?", Option for "what did we see?")

| Component | Types/ (Production) | CoTypes/ (Observation) |
|-----------|--------------------|-----------------------|
| Specification | `Hom/{Phase}/` — what to provide | `CoHom/{Phase}/` — what to check |
| Executor | `IO/IO{Phase}Phase/` — produce system state | `CoIO/CoIO{Phase}Phase/` — probe system state |
| Result | `Product/{Phase}/` — what was produced | `CoProduct/{Phase}/` — what was observed |
| Effect type | `Monad/` — errors, build/switch results | `Comonad/` — observation traces, history |

## Type-Theoretic Categories (7)

Every type in the system belongs to exactly one of 7 categories. No exceptions.

| # | Category | Type Theory | Matter | Symmetry | Directory |
|---|----------|-------------|--------|----------|-----------|
| 1 | Identity | Unit (⊤) | BEC | Trivial {e} | `Types/Identity/` |
| 2 | Inductive | ADT / Sum | Crystalline | Space group | `Types/Inductive/` |
| 3 | Dependent | Indexed / Fibered | Liquid Crystal | Partial SO(3) | `Types/Dependent/` |
| 4 | Hom | Function (A → B) | Liquid | SO(3) | `Types/Hom/` |
| 5 | Product | Product / Sum | Gas | E(3) | `Types/Product/` |
| 6 | Monad | Monad (M A) | Plasma | Gauge | `Types/Monad/` |
| 7 | IO | IO | QGP | Deconfined | `Types/IO/` |

Fractal: same 7 categories recurse at every level.

## Coalgebraic Dual (1-1 Correspondence)

Every category in Types/ has exactly one dual in CoTypes/. No exceptions.

| # | Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|---|--------|----------|---------|-------------------|
| 1 | `Identity/` | `CoIdentity/` | Terminal ↔ Coterminal | Introspection witnesses — what can be observed about a terminal object (package installed? key present?) |
| 2 | `Inductive/` | `CoInductive/` | Free ↔ Cofree | Elimination forms — parsers, validators, exhaustiveness witnesses for each ADT |
| 3 | `Dependent/` | `CoDependent/` | Fibration ↔ Cofibration | Lifting property — schema conformance validators, "does this observation inhabit the fiber?" |
| 4 | `Hom/` | `CoHom/` | Constructors ↔ Destructors | Observation specifications — field-parallel to Hom/ with observation types (Bool, Option) |
| 5 | `Product/` | `CoProduct/` | Product ↔ Coproduct | Observation results — what the observer actually saw per phase (Output + Meta) |
| 6 | `Monad/` | `Comonad/` | Effects ↔ Co-effects (traces) | Observation traces — extract (current observation) + extend (map over history) |
| 7 | `IO/` | `CoIO/` | Executors ↔ Observers | Observer executors — Nix scripts that probe system state and compare against CoHom expectations |

## Justfile Commands as Functors (6-Functor Formalism)

Every justfile command is a morphism classified by the 6-functor formalism (Grothendieck):

```
f* ⊣ f*    (pullback ⊣ pushforward)         — inverse/direct image
f! ⊣ f!    (shriek pullback ⊣ shriek push)  — compact support
⊗  ⊣ Hom   (tensor ⊣ internal hom)          — monoidal structure
```

Three command prefixes:

| Prefix | Recursion Scheme | 6FF Functors | Direction | Maps to |
|--------|-----------------|--------------|-----------|---------|
| `ana-` | Anamorphism (unfold) | f*, f!, Hom | Observe / extract | CoTypes/ |
| `cata-` | Catamorphism (fold) | f*, f! | Produce / deploy | Types/ |
| `hylo-` | Hylomorphism (unfold+fold) | ⊗ (tensor) | Composite: ana then cata | Types/ ⊗ CoTypes/ |

**Testing = coalgebraic observation.** Every `cata-*` has an `ana-*` dual. Validation is not a separate concern — it is the CoIO mapping of the IO executor.

### Justfile → 6FF Mapping

| Recipe | Prefix | 6FF | Type/CoType |
|--------|--------|-----|-------------|
| `ana-check` | ana | f! (shriek pullback) | CoIO |
| `ana-show` | ana | f* (pullback) | CoProduct |
| `ana-eval {path}` | ana | f* (pullback) | CoProduct |
| `ana-keys {path}` | ana | Hom (internal) | CoInductive |
| `ana-identity` | ana | f* (pullback) | CoProduct/Identity |
| `ana-platform` | ana | f* (pullback) | CoProduct/Platform |
| `ana-network` | ana | f* (pullback) | CoProduct/Network |
| `ana-services` | ana | f* (pullback) | CoProduct/Services |
| `ana-user` | ana | f* (pullback) | CoProduct/User |
| `ana-workspace` | ana | f* (pullback) | CoProduct/Workspace |
| `ana-deploy` | ana | f* (pullback) | CoProduct/Deploy |
| `ana-types-validate` | ana | f! (shriek pullback) | CoHom |
| `ana-size {path}` | ana | f* (pullback) | CoIdentity |
| `ana-search {query}` | ana | f* (pullback) | CoInductive |
| `ana-info {pkg}` | ana | f* (pullback) | CoIdentity |
| `ana-repl` | ana | f* (pullback) | CoIO |
| `cata-types-build` | cata | f! (shriek push) | IO (Lake) |
| `cata-build {machine}` | cata | f! (shriek push) | Product/Deploy |
| `cata-switch {host}` | cata | f* (pushforward) | Product/Deploy |
| `cata-flash {m} {disk}` | cata | f* (pushforward) | Product/Deploy |
| `cata-update` | cata | f* (pushforward) | Identity (flake.lock) |
| `cata-gc {days}` | cata | f! (shriek push) | IO |
| `cata-optimize` | cata | f! (shriek push) | IO |
| `cata-sync-to {host}` | cata | f* (pushforward) | IO |
| `cata-ssh {machine}` | cata | f* (pushforward) | IO |
| `hylo-main {host}` | hylo | ⊗ (tensor) | ana-types-validate ⊗ cata-switch |
| `hylo-remote-build` | hylo | ⊗ (tensor) | cata-sync-to ⊗ cata-build |
| `hylo-remote-switch` | hylo | ⊗ (tensor) | cata-sync-to ⊗ cata-switch |
| `hylo-dev {shell}` | hylo | ⊗ (tensor) | ana-eval ⊗ cata-run |

## Import DAG (strictly layered)

```
Identity ← Inductive ← Dependent ← Hom ← Product
                                         ↗
                                   Monad
                                         ↗
                                   IO
```

No upward imports. Monad and IO are terminal — they may reference all lower layers.

## User Sub-Phases (7)

IOUserPhase (Product at top level) contains 7 sub-phases following the same category chain:

| # | Sub-Phase | Hom | Product |
|---|-----------|-----|---------|
| 1 | Identity | `Hom/User/Identity/` | `Product/User/Identity/` |
| 2 | Credentials | `Hom/User/Credentials/` | `Product/User/Credentials/` |
| 3 | Shell | `Hom/User/Shell/` | `Product/User/Shell/` |
| 4 | Terminal | `Hom/User/Terminal/` | `Product/User/Terminal/` |
| 5 | Editor | `Hom/User/Editor/` | `Product/User/Editor/` |
| 6 | Comms | `Hom/User/Comms/` | `Product/User/Comms/` |
| 7 | Packages | `Hom/User/Packages/` | `Product/User/Packages/` |

## Deployment Targets (Domain Closure)

The project is domain-complete when every row is producible and observable:

| Target | Platform | Format | cata- | ana- |
|--------|----------|--------|-------|------|
| MacBook (darwin) | aarch64-darwin | homeConfiguration | `cata-switch darwin` | `ana-{phase}` |
| Cloud dev box | x86_64-linux | homeConfiguration | `cata-switch cloud-dev` | `ana-{phase}` |
| NixOS workstation | x86_64-linux | nixosConfiguration | `cata-switch nixos` | `ana-{phase}` |
| Cyberdeck | x86_64-linux | ISO | `cata-build cyberdeck` | `ana-{phase}` |
| VM | x86_64-linux | VM image | `cata-build vm` | `ana-{phase}` |
| MicroVM | x86_64-linux | microvm | `cata-build microvm` | `ana-{phase}` |

## Naming Convention (FROZEN)

- `Types/` — Lean source: `Default.lean` per directory, organized into 7 categories
- `CoTypes/` — Lean source: `Default.lean` per directory, 1-1 dual of Types/
- `Types/IO/` — Lake project root + Nix IO executors: `lakefile.lean`, `lean-toolchain`, `IO{Phase}Phase/{default.nix, default.json}`
- `ana-{cmd}` — coalgebraic observation (anamorphism)
- `cata-{cmd}` — algebraic production (catamorphism)
- `hylo-{cmd}` — composite unfold+fold (hylomorphism)
- No files exist outside canonical 7-category directories (including build toolchain files)

## Invariants

1. Types/ and CoTypes/ are at repo root. The repo root IS the type universe.
2. Every type belongs to exactly one of 7 categories: Identity, Inductive, Dependent, Hom, Product, Monad, IO.
3. Every category in Types/ has exactly one dual in CoTypes/. 1-1 correspondence. No exceptions.
4. Types/IO/ is the Lake project root and hosts all Nix IO executors. No files outside canonical dirs.
5. File naming: `Default.lean` for Lean. `default.*` for Nix/JSON.
6. NO import-tree. IOMainPhase imports phases 1-6 and implements phase 7 (Deploy).
7. NO options blocks in IO executors. All typing in Lean. IO executors read JSON.
8. NO nulls — all params bounded with defaults in Lean structures.
9. NO vendor names in Types (handle in IO executors).
10. NO bare `String` for finite variants. Every string-that-is-an-enum is an `Inductive` ADT.
11. Import DAG is strictly layered: Identity ← Inductive ← Dependent ← Hom ← Product. No upward imports.
12. Monad and IO are terminal in the import DAG — they may reference all lower layers.
13. 1-1-1 invariant: every Phase has Hom × Product(Output + Meta) × IO executor.
14. ≤7 phases per module.
15. default.json is committed (like a lock file). Regenerated via `ana-types-validate`.
16. Every `just` command is a classified morphism: `ana-` (coalgebraic), `cata-` (algebraic), or `hylo-` (tensor). No unprefixed commands.
17. One Lake project for all Lean types under Types/IO/.
18. Sub-projects (RL, Fab, Sovereignty) are separate Universes with own Types/CoTypes. Not sub-dirs.
19. User phase is shallow — tool selections only. Heavy tool configs are separate flakes consumed as Identity types.
20. Workspace phase is shallow — base toolchains only. Per-project envs live in project repos.
21. Directory placement IS typing. The path is the type annotation. No exceptions.
22. Every filetype has a canonical category. No unclassified filetypes.
23. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual.
24. The 6-functor formalism classifies all morphisms: f* (pullback/pushforward), f! (shriek), ⊗ (tensor), Hom (internal).
25. Phase placement is determined solely by type theory — not domain convenience.
26. Invariants are never traded away for convenience. No exceptions.
27. Docs first. Always.
28. nixpkgs pinned to stable release (nixos-25.11). NO unstable.
29. CoTypes/ is the bidirectional path closure witness: schema test (path a) + runtime validation (path b). Both paths yield CoProduct. Agreement = correctness.

## Anti-Patterns

- Options blocks in IO executors → typing lives in Lean Types/
- Import-tree → explicit imports in IOMainPhase
- Vendor names in Types → handle in IO executors
- `null`, `""` as default → explicit bounded default in Lean structure
- Type with >7 params → decompose into sub-structures
- Bare `String` for finite variant → extract to `Inductive/` as `inductive` type
- File outside canonical 7-category dir → move to correct category
- Unprefixed justfile recipe → classify as ana-/cata-/hylo-
- Missing CoTypes dual → every Types/ category has 1-1 CoTypes/ dual
- Upward import in DAG → Identity ← Inductive ← Dependent ← Hom ← Product only
- Heavy inline tool config in User phase → extract to separate flake, consume as Identity type
- Sub-project inside IOWorkspacePhase → separate Universe with own Types/CoTypes
- Using the word "config" → it is a dependent type serving as the domain of a morphism

## Toolchain

| Tool | Role |
|------|------|
| Lean 4 | Canonical types, compile-time checking, JSON export |
| Nix + flake-parts | Module system, derivation building, packaging |
| justfile | Morphism dispatcher — ana-/cata-/hylo- classified commands |
| gum | Styled terminal output |
