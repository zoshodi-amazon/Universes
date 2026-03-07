# Universes

A monorepo of **typed artifact labs** — each lab produces a specific class of typed artifacts using a shared algebraic/coalgebraic formalism.

## Architecture

```
Universes/
├── SystemLab/    — system-level NixOS/nix-darwin configurations
├── HomeLab/      — user-level home-manager configurations
└── README.md     — this file (universal invariants)
```

Each lab follows the same fractal structure:

```
<Lab>/
├── Types/        — algebraic (production, catamorphic)
│   ├── Identity/     — terminal objects (BEC)
│   ├── Inductive/    — ADTs / sum types (Crystalline)
│   ├── Dependent/    — parameterized configs (Liquid Crystal)
│   ├── Hom/          — phase input morphisms (Liquid)
│   ├── Product/      — phase outputs: Meta + Output (Gas)
│   ├── Monad/        — effect types (Plasma)
│   └── IO/           — phase executors: default.json + default.nix (QGP)
├── CoTypes/      — coalgebraic dual (observation, anamorphic)
│   ├── CoIdentity/   — coterminal introspection witnesses
│   ├── CoInductive/  — cofree elimination forms, validators
│   ├── CoDependent/  — cofibration schema conformance
│   ├── CoHom/        — observation specifications
│   ├── CoProduct/    — observation results
│   ├── Comonad/      — observation traces (extract + extend)
│   └── CoIO/         — observer executors
├── AGENTS.md     — lab-specific invariants
├── DICTIONARY.md — type glossary
└── TRACKER.md    — type counts and deployment targets
```

## Universal Invariants

These apply to **every lab** in the Universes monorepo:

1. **One type per file** — each `Default.lean` contains exactly one `inductive` or `structure` declaration. Re-export files aggregate sub-modules via `import`.

2. **IO/ capped at 7 subdirectories** — the 7 canonical phases of artifact production. Each phase has `default.json` (typed config) and `default.nix` (IO executor).

3. **Project boundary = artifact type** — "what typed artifact are we producing?" defines the lab boundary.

4. **Types/ and CoTypes/ maintain 1:1 duality** — every algebraic category has a coalgebraic dual.

5. **Minimal orthogonal generating set** — at each stratum, the minimum necessary types/subdirs to span the space.

6. **Lean types are the source of truth** — JSON is the typed boundary between Lean and Nix. Nix is the IO executor.

7. **`local.json` for deployment-site secrets** — never committed, `.gitignore`'d. Dependent types indexed over deployment site.

8. **Fractal self-similarity** — if a phase needs sub-phases, apply the same 7-category structure recursively.

## Labs

| Lab | Artifact | Language | Status |
|-----|----------|----------|--------|
| SystemLab | nixosConfigurations, darwinConfigurations | Lean 4 + Nix | active |
| HomeLab | homeConfigurations (user dotfiles) | Lean 4 + Nix | scaffold |

## Type-Theoretic Formalism

The 7 categories form a **phase diagram** analogous to states of matter:

| # | Category | State | Role |
|---|----------|-------|------|
| 1 | Identity | BEC | Terminal objects — unique canonical forms |
| 2 | Inductive | Crystalline | ADTs — finite enums with discrete symmetry |
| 3 | Dependent | Liquid Crystal | Indexed families — configs parameterized by inductives |
| 4 | Hom | Liquid | Morphisms — phase input bundles |
| 5 | Product | Gas | Outputs — phase results (Meta + Output) |
| 6 | Monad | Plasma | Effects — errors, build/switch/validation results |
| 7 | IO | QGP | Executors — JSON config + Nix realization |

The CoTypes mirror this with the coalgebraic dual at each level, enabling bidirectional verification (schema observation + runtime observation = path closure).
