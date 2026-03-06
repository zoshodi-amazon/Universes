# UNIVERSES(7) - Typed Device Configuration

## NAME

Universes - Typed phase pipeline for device configuration. One operator × N hardware targets. Lean 4 types (7 categories) → JSON → Nix IO executors.

## DOMAIN BOUNDARY

This Universe configures **devices**. The domain is closed around: one human operator × N hardware deployment targets. The end artifact is a complete, reproducible, type-checked configuration for any device.

Sub-projects (RL trading, fabrication, sovereignty) are **separate Universes** with their own Types/CoTypes and domain-specific 7-phase chains. From this Universe's perspective they are Identity types (opaque packages).

**"Done"** = every target device in the deployment table can be produced by `cata-build {target}` and fully observed by `ana-{phase} {target}`.

## SYNOPSIS

```
Universes/
├── Types/                         # Lean 4 — the type space (7 categories)
│   ├── Identity/                  # [BEC] Unit (⊤) — terminal objects
│   ├── Inductive/                 # [Crystalline] ADT / Sum — finite enums
│   ├── Dependent/                 # [Liquid Crystal] Indexed — parameterized types
│   ├── Hom/                       # [Liquid] Function (A → B) — phase inputs
│   ├── Product/                   # [Gas] Product (A × B) — phase outputs + meta
│   ├── Monad/                     # [Plasma] Monad (M A) — effect types
│   └── IO/                        # [QGP] IO — Lake project root + Nix IO executors
│       ├── lakefile.lean
│       ├── lean-toolchain
│       ├── Default.lean           # Validation entry point
│       ├── IO{Phase}Phase/        # Nix modules: default.nix + default.json
│       └── Env/                   # Tracker docs
├── CoTypes/                       # Coalgebraic dual of Types/ (1-1)
│   ├── CoIdentity/                # Terminal ↔ Coterminal
│   ├── CoInductive/               # Free ↔ Cofree
│   ├── CoDependent/               # Fibration ↔ Cofibration
│   ├── CoHom/                     # Constructors ↔ Destructors
│   ├── CoProduct/                 # Product ↔ Coproduct
│   ├── Comonad/                   # Effects ↔ Co-effects (traces)
│   └── CoIO/                      # Executors ↔ Observers
├── flake.nix                      # Hom (A → B) — top-level morphism
├── flake.lock                     # Identity (⊤) — terminal object
├── justfile                       # IO/CoIO dispatcher — ana-/cata-/hylo-
├── AGENTS.md                      # CoIO — system observation
├── README.md                      # CoIO — system observation
├── DICTIONARY.md                  # CoIO — formal glossary
└── TRACKER.md                     # CoIO — implementation state
```

**Pattern Version: v5.1.0**

## DESCRIPTION

Every phase is a profunctor: typed input (Hom) → effectful arrow (IO executor) → typed output (Product). The type system is Lean 4 (compile-time checked, 7 type-theoretic categories). The IO boundary is JSON (default.json). The arrow layer is Nix (flake-parts modules reading `builtins.fromJSON`). The nix store is the ambient IO — the universal typed filesystem.

There are no "configurations" — there are dependent types serving as domains of morphisms.

### Architecture

```
Types/ (Lean 4)  →  default.json  →  Types/IO/ (Nix)
7-category DSL      IO boundary      IO executors (builtins.fromJSON → module API)

CoTypes/ (Lean 4) — Coalgebraic dual of Types/ (1-1 correspondence)
```

### Directory Placement IS Typing

Every file belongs to exactly one of 14 directories (7 Types + 7 CoTypes). The directory path IS the type annotation. Placing a file in `Types/Hom/Identity/` declares it as a morphism into the Identity phase. There is no separate type declaration — the filesystem is the type system.

### Filetype Classification

| Extension | Category | Rationale |
|-----------|----------|-----------|
| `.lean` | Any (determined by directory) | Type definitions — source of truth |
| `.nix` | IO (always `Types/IO/`) | Effect executors — profunctor arrows |
| `.json` | IO boundary (`Types/IO/`) | Serialized Hom types at the IO boundary |
| `.md` | CoIO / Comonad | Observation — describes without modifying |
| `.toml` | Dependent | Build parameterization |
| `.lock` | Identity | Terminal object — one canonical inhabitant |

### Phase Chain

```
Identity → Platform → Network → Services → User → Workspace → Deploy
(Unit/⊤)   (ADT)      (Indexed)  (A → B)    (A×B)  (M A)       (IO)
```

| # | Phase | Type Theory | Matter | Domain |
|---|-------|-------------|--------|--------|
| 1 | Identity | Unit (⊤) | BEC | Secrets, keys, Nix daemon, user account |
| 2 | Platform | Inductive (ADT) | Crystalline | Boot, disk, hardware, display, peripherals |
| 3 | Network | Dependent (Indexed) | Liquid Crystal | Firewall, SSH, wireless, VPN, DNS |
| 4 | Services | Hom (A → B) | Liquid | Containers, daemons, databases |
| 5 | User | Product (A × B) | Gas | Shell, terminal, editor, browser, CLI tools |
| 6 | Workspace | Monad (M A) | Plasma | DevShells, language toolchains, build systems |
| 7 | Deploy | IO | QGP | homeConfigurations, nixosConfigurations, ISOs, VMs |

### Profunctor Pattern

```
Hom(phase)  ──IO executor──▸  Product(phase)
  (domain)    (default.nix)      (codomain)
```

### Observation Pipeline (Coalgebraic Dual)

Production and observation are dual paths. CoTypes/ is the bidirectional path closure witness.

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

- Path (a): **Schema observation** — `Hom → toJson → fromJson → Hom` roundtrip closure (`ana-types-validate`)
- Path (b): **Runtime observation** — `Product → CoIO observer → CoProduct` system probing (`ana-{phase}`)
- Agreement between (a) and (b) = **bidirectional path closure** = system correctness

Production (Types/ → IO → Product) is the **free** direction. Observation (Product → CoIO → CoProduct) is the **forgetful** direction. The free-forgetful adjunction `F ⊣ U` is the formal statement that the system is well-typed.

### Coalgebraic Dual (1-1)

| Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|--------|----------|---------|-------------------|
| `Identity/` | `CoIdentity/` | Terminal ↔ Coterminal | Introspection witnesses (installed? present?) |
| `Inductive/` | `CoInductive/` | Free ↔ Cofree | Elimination forms, parsers, validators |
| `Dependent/` | `CoDependent/` | Fibration ↔ Cofibration | Schema conformance, lifting validators |
| `Hom/` | `CoHom/` | Constructors ↔ Destructors | Observation specs (field-parallel, Bool/Option) |
| `Product/` | `CoProduct/` | Product ↔ Coproduct | Observation results (what was seen) |
| `Monad/` | `Comonad/` | Effects ↔ Co-effects | Traces — extract + extend over history |
| `IO/` | `CoIO/` | Executors ↔ Observers | Observer scripts — probe and compare |

### Import DAG

```
Identity ← Inductive ← Dependent ← Hom ← Product
                                         ↗
                                   Monad
                                         ↗
                                   IO
```

## OPTIONS

Every justfile command is a classified morphism (6-functor formalism):

```
ana-{cmd}   — anamorphism  — coalgebraic observation (f*, f!, Hom)
cata-{cmd}  — catamorphism — algebraic production (f*, f!)
hylo-{cmd}  — hylomorphism — tensor composite: ana then cata (⊗)
```

### Anamorphisms (observe / extract → CoTypes/)

```
ana-check                   # f! shriek pullback — CoIO
ana-show                    # f* pullback — CoProduct
ana-eval {path}             # f* pullback — CoProduct
ana-keys {path}             # Hom internal — CoInductive
ana-identity                # f* pullback — CoProduct/Identity
ana-platform                # f* pullback — CoProduct/Platform
ana-network                 # f* pullback — CoProduct/Network
ana-services                # f* pullback — CoProduct/Services
ana-user                    # f* pullback — CoProduct/User
ana-workspace               # f* pullback — CoProduct/Workspace
ana-deploy                  # f* pullback — CoProduct/Deploy
ana-types-validate          # f! shriek pullback — CoHom
ana-size {path}             # f* pullback — CoIdentity
ana-search {query}          # f* pullback — CoInductive
ana-info {pkg}              # f* pullback — CoIdentity
ana-repl                    # f* pullback — CoIO
```

### Catamorphisms (produce / deploy → Types/)

```
cata-types-build            # f! shriek push — IO (Lake)
cata-build {machine}        # f! shriek push — Product/Deploy
cata-switch {host}          # f* pushforward — Product/Deploy
cata-flash {m} {disk}       # f* pushforward — Product/Deploy
cata-update                 # f* pushforward — Identity (flake.lock)
cata-gc {days}              # f! shriek push — IO
cata-optimize               # f! shriek push — IO
cata-sync-to {host}         # f* pushforward — IO
cata-ssh {machine}          # f* pushforward — IO
```

### Hylomorphisms (unfold + fold → Types/ ⊗ CoTypes/)

```
hylo-main {host}            # ⊗ tensor — ana-types-validate ⊗ cata-switch
hylo-remote-build {h} {m}   # ⊗ tensor — cata-sync-to ⊗ cata-build
hylo-remote-switch {h}      # ⊗ tensor — cata-sync-to ⊗ cata-switch
hylo-dev {shell}            # ⊗ tensor — ana-eval ⊗ cata-run
```

## DEPLOYMENT TARGETS

| Target | Platform | Format | cata- | ana- |
|--------|----------|--------|-------|------|
| MacBook (darwin) | aarch64-darwin | homeConfiguration | `cata-switch darwin` | `ana-{phase}` |
| Cloud dev box | x86_64-linux | homeConfiguration | `cata-switch cloud-dev` | `ana-{phase}` |
| NixOS workstation | x86_64-linux | nixosConfiguration | `cata-switch nixos` | `ana-{phase}` |
| Cyberdeck | x86_64-linux | ISO | `cata-build cyberdeck` | `ana-{phase}` |
| VM | x86_64-linux | VM image | `cata-build vm` | `ana-{phase}` |
| MicroVM | x86_64-linux | microvm | `cata-build microvm` | `ana-{phase}` |

## CAVEATS

See AGENTS.md for full invariant list (29 invariants). Key constraints:

1. Directory placement IS typing. The path is the type annotation. No exceptions.
2. Every `just` command is a classified morphism: `ana-`, `cata-`, or `hylo-`. No unprefixed commands.
3. Testing = coalgebraic observation. Every `cata-*` has an `ana-*` dual.
4. CoTypes/ is the bidirectional path closure witness: schema test + runtime validation.
5. User phase is shallow — tool selections only. Heavy configs are separate flakes.
6. Sub-projects are separate Universes. Not sub-dirs.
7. No bare `String` for finite variants. No nulls. No options blocks in IO executors.
8. Invariants are never traded away for convenience. No exceptions.
9. Docs first. Always.

## HISTORY

| Version | Date | Changes |
|---------|------|---------|
| v5.1.0 | 2026-03-06 | Observation pipeline (dual paths a/b), CoTypes path closure witness, bidirectional free-forgetful adjunction, DICTIONARY + TRACKER, enriched CoTypes content descriptions |
| v5.0.1 | 2026-03-05 | Domain boundary, directory-IS-typing, filetype classification, ana/cata/hylo 6FF justfile convention, profunctor pattern, deployment targets, Monads absorbed into Types/IO/, sub-projects separated |
| v5.0.0 | 2026-03-05 | Types/ + CoTypes/ at repo root, 7-category type system, full 1-1 coalgebraic duality |
| v4.1.0 | 2026-03-02 | IOPipelinePhase → IOMainPhase, IOUserPhase 7 sub-phases, matter-phase framework |
| v4.0.0 | 2026-03-01 | Lean Types + JSON boundary + Nix Monads, 7-phase pipeline |
| v3.0.0 | 2026-02-26 | Unified monadic framing, matter-phase type system, 1-1-1 invariant |
