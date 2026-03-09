# Universes

A monorepo of **typed artifact labs** -- each lab produces a specific class of typed artifacts using a shared algebraic/coalgebraic formalism.

---

## Foundations

This is a **solo-researcher system**. One human operator, N typed artifact factories. It is not optimized for team onboarding, enterprise readability, or consensus-driven design. It is optimized for mathematical precision and cognitive efficiency.

**Programs are proofs.** The Curry-Howard correspondence is not a metaphor here. Lean 4 programs are constructive proofs, the filesystem directory structure is a concrete model of a type theory, and every artifact produced by the system is a witness to a type-theoretic proposition. Software engineers are the working mathematicians of the 21st century; this system takes that literally.

**Lean 4 is the formal backbone.** The 7-category filesystem structure (Identity, Inductive, Dependent, Hom, Product, Monad, IO) is not a convention or style guide. It IS a type theory. Lean 4 verifies the algebraic side at compile time. Other languages -- Python (pydantic), Rust (serde), Nix -- inhabit the IO layer. They read typed JSON at the IO boundary and execute effectful morphisms, but they do not define the type theory. The types are the source of truth; everything else is a projection.

**The matter-phase naming is geometric binding.** The BEC -> Crystalline -> Liquid Crystal -> Liquid -> Gas -> Plasma -> QGP naming that labels the 7 categories is a **stratified information gradient** grounded in symmetry groups:

| # | Phase | Symmetry | Degrees of Freedom |
|---|-------|----------|-------------------|
| 1 | BEC (Identity) | Trivial {e} | 0 -- one canonical form, frozen |
| 2 | Crystalline (Inductive) | Space group | Finite -- discrete enumerated variants |
| 3 | Liquid Crystal (Dependent) | Partial SO(3) | Indexed -- parameterized over discrete choices |
| 4 | Liquid (Hom) | SO(3) | Continuous -- morphisms flow freely |
| 5 | Gas (Product) | E(3) | Expanding -- outputs proliferate |
| 6 | Plasma (Monad) | Gauge | Charged -- effects carry side-channel information |
| 7 | QGP (IO) | Deconfined | Maximal -- full interaction with external world |

Each stratum has strictly more degrees of freedom than the one below. This is analogous to the renormalization group flow in physics -- each layer integrates out finer structure. The naming is not decorative. It is the cognitive optimization layer: you can *see* where you are in the information hierarchy by the phase name, and the symmetry group tells you exactly how many degrees of freedom that stratum permits.

**Names are first-class citizens.** Directory names ARE types. Filenames are always `default.*` -- the filename carries zero semantic content. All type identity lives in the directory path. This is a theorem of the system, not a naming guideline. If you are tempted to encode meaning in a filename, you need a subdirectory instead.

**No ad-hoc implementations.** If a file cannot be placed in exactly one of the 14 directories (7 Types + 7 CoTypes), it does not exist yet. There is no "experimenting," no "trying things out," no scratch space. Every artifact has a type-theoretic address or it is not part of the system. Adherence to the type-theoretic framework is the invariant that makes everything else possible.

**Every CS concept has a type-theoretic grounding.** A/B testing, feature flags, caching, microservices, CI/CD, observability -- these are not ad-hoc engineering patterns. They are instances of well-defined category-theoretic structures (coproduct injections, dependent types over boolean fibers, idempotent endofunctors, products of profunctors, hylomorphisms, coalgebraic observation). See `DICTIONARY.md` for the comprehensive mapping. If a concept cannot be grounded type-theoretically, it is not understood yet.

**The Type Universe is a sheaf.** Each lab is a local section of a sheaf over the space of artifact domains. The universal invariants are the restriction maps. Creating a new lab is reduced to instantiating 7 fibers (one per stratum) -- see `TEMPLATE.md` Section 13. See `DICTIONARY.md` for the full sheaf-theoretic vocabulary.

---

## Architecture

```
Universes/
├── SystemLab/      -- system-level NixOS/nix-darwin configurations (Lean 4 + Nix)
├── HomeLab/        -- user-level home-manager configurations (Lean 4 + Nix)
├── MaterialLab/    -- physical material fabrication (Lean 4 + Python)
├── PlatformLab/    -- hardware platform / firmware definition (Lean 4 + Rust)
├── RL-Lab/         -- autonomous quant RL pipeline (Lean 4 + Python)
├── IntelLab/       -- (TBD)
├── AGENTS.md       -- universal type-theoretic invariants (single source of truth)
├── DICTIONARY.md   -- universal formal glossary + Rosetta stone
├── TEMPLATE.md     -- universal naming, structural templates, Lean type templates
├── TRACKER.md      -- cross-lab formalism tracker
└── README.md       -- this file
```

**Lean 4 defines strata 1-6 for every lab.** IO-layer languages (Nix, Python, Rust) execute stratum 7. The JSON codec (`default.json`) mediates the boundary. See `AGENTS.md` for the Lean Canonical Primacy section and `TEMPLATE.md` Section 15 for the Lean-to-IO projection table.

Each lab follows the same fractal structure:

```
{Lab}/
├── Types/        -- algebraic (production, catamorphic)
│   ├── Identity/     -- terminal objects (BEC)
│   ├── Inductive/    -- ADTs / sum types (Crystalline)
│   ├── Dependent/    -- parameterized structures (Liquid Crystal)
│   ├── Hom/          -- phase input morphisms (Liquid)
│   ├── Product/      -- phase outputs: Meta + Output (Gas)
│   ├── Monad/        -- effect types (Plasma)
│   └── IO/           -- phase executors: default.json + default.{ext} (QGP)
├── CoTypes/      -- coalgebraic dual (observation, anamorphic)
│   ├── CoIdentity/   -- coterminal introspection witnesses
│   ├── CoInductive/  -- cofree elimination forms, validators
│   ├── CoDependent/  -- cofibration schema conformance
│   ├── CoHom/        -- observation specifications
│   ├── CoProduct/    -- observation results
│   ├── Comonad/      -- observation traces (extract + extend)
│   └── CoIO/         -- observer executors
├── AGENTS.md     -- lab-specific invariants (extends Universes/AGENTS.md)
├── DICTIONARY.md -- domain-specific glossary (extends Universes/DICTIONARY.md)
├── TEMPLATE.md   -- lab-specific naming (extends Universes/TEMPLATE.md)
└── TRACKER.md    -- per-type implementation state (extends Universes/TRACKER.md)
```

## Universal Invariants

See `AGENTS.md` for the full list (32 invariants). The non-negotiable foundation:

- **Lean 4 is the canonical DSL** for strata 1-6 in every lab. IO-layer languages are projections. No exceptions.
- **Adherence to the type-theoretic framework is unconditional.** It is never traded for convenience. Violations are ill-typed artifacts, not pragmatic trade-offs.
- **One type per file** -- all filenames are `default.*`. The type name is the directory path.
- **Types/ and CoTypes/ maintain 1:1 duality** -- every algebraic category has a coalgebraic dual.
- **Fractal self-similarity** -- the same 7-category structure recurses at every level.

## Labs

| Lab | Artifact | Lean 4 Types | IO Runtime | Status |
|-----|----------|-------------|------------|--------|
| SystemLab | nixosConfigurations, darwinConfigurations | Yes | Nix | active (v5.3.0) |
| HomeLab | homeConfigurations (user dotfiles) | Yes (scaffold) | Nix | scaffold (v0.1.0) |
| MaterialLab | 3D prints, CNC parts, laser-cut assemblies | Provisional (Python) | Python | active (v0.2.0) |
| PlatformLab | Firmware images, board definitions | Provisional (Rust) | Rust + Nix | scaffold (v0.1.0) |
| RL-Lab | Autonomous quant RL pipeline (single-asset) | Provisional (Python) | Python | active (v0.3.0) |

## Type-Theoretic Formalism

The 7 categories form a **phase diagram** analogous to states of matter:

| # | Category | State | Role |
|---|----------|-------|------|
| 1 | Identity | BEC | Terminal objects -- unique canonical forms |
| 2 | Inductive | Crystalline | ADTs -- finite enums with discrete symmetry |
| 3 | Dependent | Liquid Crystal | Indexed families -- structures parameterized by inductives |
| 4 | Hom | Liquid | Morphisms -- phase input bundles |
| 5 | Product | Gas | Outputs -- phase results (Meta + Output) |
| 6 | Monad | Plasma | Effects -- errors, build/validation results |
| 7 | IO | QGP | Executors -- JSON boundary + effectful realization |

The CoTypes mirror this with the coalgebraic dual at each level, enabling bidirectional verification (schema observation + runtime observation = path closure).

## Docs

| Doc | Scope | Content |
|-----|-------|---------|
| `AGENTS.md` | Universal | All type-theoretic invariants, architecture, anti-patterns |
| `DICTIONARY.md` | Universal | Formal definitions of every type-theoretic term |
| `TEMPLATE.md` | Universal | Directory templates, naming conventions, file classification |
| `TRACKER.md` | Universal | Cross-lab dashboard, dependency graph, compliance |
| `{Lab}/AGENTS.md` | Domain | Lab-specific phase chain, deployment targets, toolchain |
| `{Lab}/DICTIONARY.md` | Domain | Lab-specific terms (tools, formats, domain concepts) |
| `{Lab}/TEMPLATE.md` | Domain | Lab-specific phase names, language conventions |
| `{Lab}/TRACKER.md` | Domain | Per-type implementation state, infrastructure gaps |
