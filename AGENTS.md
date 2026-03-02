# AGENTS.md

Agent-optimized context for the Universes repository.

Pattern Version: v4.1.0 | Structure: FROZEN

## Architecture

```
Types/ (Lean 4)           →  default.json  →  Monads/ (Nix)
ADTs + deriving ToJson       IO boundary      builtins.fromJSON → module API calls
```

## Phase Chain

```
Identity → Platform → Network → Services → User → Workspace → Deploy
```

7 phases + 1 entry point. IOMainPhase is the single entry point.

## Monadic Identity

- Types/ = Lean 4 ADTs with `deriving ToJson, FromJson` (compile-time typed)
- default.json = IO boundary (committed, like a lock file)
- Monads/ = Nix flake-parts modules (`builtins.fromJSON` → module API calls)
- IOMainPhase = entry point, explicitly imports 6 phases + inline deploy
- flake.nix imports only `Modules/Monads/IOMainPhase`
- Every `just` command maps to IOMainPhase

## Matter-Phase Type System

| # | Matter | Type Theory | Category Theory | HoTT | Symmetry | Domain (Top) | Domain (User) |
|---|--------|-------------|-----------------|------|----------|-------------|---------------|
| 1 | BEC | Unit (⊤) | Terminal object | Contractible | Trivial {e} | Identity | Identity |
| 2 | Crystalline | Inductive (ADT) | Free category | Discrete type | Space group | Platform | Credentials |
| 3 | Liquid Crystal | Dependent type | Fibered category | Fibration | Partial SO(3) | Network | Shell |
| 4 | Liquid | Function (A → B) | Morphisms | Path space | SO(3) | Services | Terminal |
| 5 | Gas | Product/Sum | Coproduct+Product | Wedge/Suspension | E(3) | User | Editor |
| 6 | Plasma | Monad (M A) | Kleisli category | Higher inductive | Gauge | Workspace | Comms |
| 7 | QGP | IO | Initial + Free | Univalent universe | Deconfined | Deploy | Packages |

Fractal: same 7 phases recurse at every level.

## Execution Stack

| Interpreter | Types | IO Boundary | Monads | Output |
|-------------|-------|-------------|--------|--------|
| Lean 4 | ADTs + `deriving ToJson` | `default.json` | — | JSON config |
| Nix | — | `builtins.fromJSON` | `config` block | `flake.*`, `perSystem.*` |
| Python | pydantic `BaseModel` | `default.json` | `IO{X}Phase` + `BaseSettings` | pydantic output models |

## Naming Convention (FROZEN)

- `Types/` — Lean source: `Default.lean` per directory
- `Monads/IO{Phase}Phase/` — Nix module: `default.nix` + `default.json`
- `just {recipe}` — all recipes map to IOMainPhase

## Invariants

1. Types/ is Lean 4. Monads/ is Nix. default.json is the IO boundary.
2. File naming: `default.*` for Nix/JSON. `Default.lean` for Lean (Lake convention).
3. NO import-tree. IOMainPhase explicitly imports 6 phases + inline deploy.
4. NO options blocks in Monads. All typing in Lean. Monads read JSON.
5. NO nulls — all params bounded with defaults in Lean structures.
6. NO vendor names in Types (handle in Monads).
7. 1-1-1 invariant: every Phase has Input × Output × Monad.
8. ≤7 phases per module (excluding IOMainPhase).
9. default.json is committed (like a lock file). Regenerated via `just types-validate`.
10. Every `just` command maps to IOMainPhase.
11. Labs (RL, Fab, Sovereignty) are self-contained sub-modules in IOWorkspacePhase.
12. Every module has Env/ with Inputs/ and Outputs/docs/tracker/.
13. Git commit messages: `[Module/Path] Description`.
14. Docs first. Always.
15. nixpkgs pinned to stable release (nixos-25.11). NO unstable.

## Anti-Patterns

- options blocks in Monads → typing lives in Lean Types/
- import-tree → explicit imports in IOMainPhase
- Vendor names in Types → handle in Monads
- `null`, `""` as default → explicit bounded default in Lean structure
- Type with >7 params → decompose into sub-structures
- Justfile recipe without phase mapping → every recipe maps to IOMainPhase
- Untyped JSON → every default.json has a corresponding Lean structure

## Toolchain

| Tool | Role |
|------|------|
| Lean 4 | Canonical types, compile-time checking, JSON export |
| Nix + flake-parts | Module system, derivation building, packaging |
| Python + pydantic | Phase types for Labs (RL, Fab) |
| justfile | Pipeline interface — all recipes map to IOMainPhase |
| gum | Styled terminal output |
