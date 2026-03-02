# UNIVERSES(7) - Phase-Based Nix Configuration System

## NAME

Universes - Typed phase pipeline for device configuration. Lean 4 types → JSON → Nix monads.

## SYNOPSIS

```
Universes/
├── Modules/
│   ├── Types/                    # Lean 4 — the type space (ADTs + deriving ToJson)
│   ├── Monads/                   # Nix — the effect space (builtins.fromJSON → module API calls)
│   └── Env/                      # Runtime substrate (Inputs/Outputs)
├── flake.nix                     # Imports Modules/Monads/IOMainPhase
├── justfile                      # Phase recipes (all map to IOMainPhase)
├── AGENTS.md
└── README.md
```

**Pattern Version: v4.1.0**

## DESCRIPTION

Every module is a monad: typed input → effectful binding → typed output. The type system is Lean 4 (compile-time checked). The IO boundary is JSON (default.json). The binding layer is Nix (flake-parts modules). The nix store is the ambient IO — the universal typed filesystem.

### Architecture

```
Types/ (Lean 4)           →  default.json  →  Monads/ (Nix)
ADTs + deriving ToJson       IO boundary      builtins.fromJSON → module API calls
compile-time typed           committed file   flake-parts modules
```

### Phase Chain

```
Identity → Platform → Network → Services → User → Workspace → Deploy
```

7 phases + 1 entry point. IOMainPhase is the single entry point.

| # | Phase | What it answers | Nix target |
|---|-------|----------------|------------|
| 1 | Identity | Nix daemon, secrets, keys | flake.modules.{hm,nixos,darwin} |
| 2 | Platform | Boot, disk, hardware, display | flake.modules.nixos |
| 3 | Network | Firewall, SSH, wireless | flake.modules.{nixos,hm} |
| 4 | Services | Containers, servers | flake.modules.nixos |
| 5 | User | Shell, editor, git, mail, browser, AI, cloud | flake.modules.homeManager |
| 6 | Workspace | DevShells, labs (RL, Fab, Sovereignty) | perSystem |
| 7 | Deploy | homeConfigurations, nixosConfigurations, ISOs, VMs | flake.* |

### Matter-Phase Type System

The 7 states of matter map to type theory, category theory, and domain-specific phases:

| # | Matter | Type Theory | Category Theory | HoTT | Symmetry | Domain (Top) | Domain (User) |
|---|--------|-------------|-----------------|------|----------|-------------|---------------|
| 1 | BEC | Unit (⊤) | Terminal object | Contractible | Trivial {e} | Identity | Identity |
| 2 | Crystalline | Inductive (ADT) | Free category | Discrete type | Space group | Platform | Credentials |
| 3 | Liquid Crystal | Dependent type | Fibered category | Fibration | Partial SO(3) | Network | Shell |
| 4 | Liquid | Function (A → B) | Morphisms | Path space | SO(3) | Services | Terminal |
| 5 | Gas | Product/Sum | Coproduct+Product | Wedge/Suspension | E(3) | User | Editor |
| 6 | Plasma | Monad (M A) | Kleisli category | Higher inductive | Gauge | Workspace | Comms |
| 7 | QGP | IO | Initial + Free | Univalent universe | Deconfined | Deploy | Packages |

The fractal property: the same 7 phases recurse at every level. IOUserPhase (Gas at top level) contains 7 sub-phases following the same matter chain.

### Execution Stack

| Interpreter | Types | IO Boundary | Monads | Output |
|-------------|-------|-------------|--------|--------|
| Lean 4 | ADTs + `deriving ToJson` | `default.json` | — | JSON config |
| Nix | — | `builtins.fromJSON` | `config` block | `flake.*`, `perSystem.*` |
| Python | pydantic `BaseModel` | `default.json` | `IO{X}Phase` + `BaseSettings` | pydantic output models |

## OPTIONS

```
just main            # IOMainPhase: validate + switch
just switch darwin   # IOMainPhase: Nix switch only
just types-build     # IOMainPhase: Build Lean type system
just types-validate  # IOMainPhase: Validate default.json against Lean schemas
```

## FILES

```
Modules/
├── Types/                             # Lean 4 Lake project
│   ├── lakefile.lean
│   ├── lean-toolchain
│   ├── Default.lean                   # IO: export entry point
│   ├── UnitTypes/Default.lean         # Pure: shared ADTs
│   ├── PhaseInputTypes/Default.lean   # Pure: 7 input structures
│   └── PhaseOutputTypes/Default.lean  # Pure: 7 output structures
├── Monads/
│   ├── IOMainPhase/default.nix    # Entry point: imports 6 phases + inline deploy
│   ├── IOIdentityPhase/
│   │   ├── default.nix                # builtins.fromJSON → nix/secrets config
│   │   └── default.json               # Lean-exported typed config
│   ├── IOPlatformPhase/               # boot, disk, hardware, display
│   ├── IONetworkPhase/                # networking, SSH
│   ├── IOServicesPhase/               # containers, servers
│   ├── IOUserPhase/                   # git, shell, editor, mail, browser, AI, cloud
│   ├── IOWorkspacePhase/              # devShells + Labs (RL, Fab, Sovereignty)
└── Env/
    ├── Inputs/
    └── Outputs/docs/tracker/
```

## CAVEATS

1. Types/ is Lean 4. Monads/ is Nix. default.json is the IO boundary.
2. File naming: `default.*` only for Nix/JSON. Lean uses `Default.lean` (Lake convention).
3. NO import-tree. IOMainPhase explicitly imports 6 phases + inline deploy.
4. NO options blocks in Monads. All typing in Lean. Monads read JSON.
5. 1-1-1 invariant: every Phase has Input × Output × Monad.
6. ≤7 phases per module (excluding IOMainPhase).
7. default.json is committed (like a lock file). Regenerated via `just types-validate`.
8. Every `just` command maps to IOMainPhase.
9. Labs (RL, Fab, Sovereignty) are self-contained sub-modules in IOWorkspacePhase.
10. _backup/ preserves all original code for reference.

## HISTORY

| Version | Date | Changes |
|---------|------|---------|
| v4.1.0 | 2026-03-02 | IOPipelinePhase → IOMainPhase, IOUserPhase 7 sub-phases, matter-phase framework, fractal rename in Labs |
| v4.0.0 | 2026-03-01 | Lean Types + JSON boundary + Nix Monads, 7-phase pipeline, drop import-tree, drop Nickel |
| v3.1.0 | 2026-02-27 | Env/ as canonical module dir, ≤7 phase invariant, tracker convention |
| v3.0.0 | 2026-02-26 | Unified monadic framing, matter-phase type system, 1-1-1 invariant |
