# TRACKER.md

Formalism tracker for the Universes monorepo. Tracks the formal structures defined at the universal level, doc completeness, and template readiness for mechanical lab instantiation.

Lab-specific TRACKER.md files track per-type implementation state within each lab. This file tracks the meta-level: is the formalism complete?

---

## Universal Docs Status

| Doc | Lines | Status | Last Updated |
|-----|-------|--------|-------------|
| README.md | ~130 | Complete | v7.1.0 |
| AGENTS.md | ~325 | Complete | v7.1.0 |
| DICTIONARY.md | ~460 | Complete | v7.1.0 |
| TEMPLATE.md | ~570 | Complete | v7.1.0 |
| TRACKER.md | (this file) | Complete | v7.1.0 |

---

## Formal Structures Defined

| Structure | Where | Status |
|-----------|-------|--------|
| 7 type-theoretic categories | AGENTS.md, TEMPLATE.md | Defined, FROZEN |
| 7 coalgebraic duals (1-1) | AGENTS.md, TEMPLATE.md | Defined, FROZEN |
| Stratified information gradient | DICTIONARY.md | Defined (BEC -> QGP) |
| CS/DevOps Rosetta stone (~50 mappings) | DICTIONARY.md | Defined (8 domains) |
| 6-Functor Formalism | AGENTS.md | Defined (f*, f!, x, Hom, f*, f!) |
| Profunctor pattern (per phase) | AGENTS.md, TEMPLATE.md | Defined + checklist |
| Observation pipeline (path a/b) | AGENTS.md | Defined |
| Bidirectional path closure | AGENTS.md, DICTIONARY.md | Defined |
| Sheaf-theoretic frame | AGENTS.md, DICTIONARY.md | Defined (8 entries) |
| Per-stratum Lean type templates | TEMPLATE.md Section 14 | Defined (strata 1-7 + CoTypes duals) |
| Sheaf section template (new lab) | TEMPLATE.md Section 13 | Defined (7-step + checklist) |
| Import DAG | AGENTS.md | Defined (strict layering) |
| 31 universal invariants | AGENTS.md | Defined |
| Anti-patterns table | AGENTS.md | Defined (13 entries) |
| Git commit format | TEMPLATE.md | Defined |
| Justfile command classification | TEMPLATE.md, AGENTS.md | Defined (ana-/cata-/hylo-) |

---

## Lab Inventory

| Lab | Artifact Type | Language | Runtime | Version | Status |
|-----|--------------|----------|---------|---------|--------|
| SystemLab | nixosConfigurations, darwinConfigurations | Lean 4 | Nix | v5.3.0 | Active |
| HomeLab | homeConfigurations (user dotfiles) | Lean 4 | Nix | v0.1.0 | Scaffold |
| MaterialLab | Physical material artifacts (3D prints, CNC, laser) | Python | pydantic | v0.2.0 | Active |
| PlatformLab | Firmware images, board definitions | Rust | Nix | v0.1.0 | Scaffold |
| RL-Lab | Autonomous quant RL pipeline (single-asset) | Python | pydantic | v0.2.0 | Active |
| IntelLab | (TBD) | -- | -- | -- | Empty |

---

## Template Readiness (Can a new lab be mechanically instantiated?)

| Requirement | Status |
|-------------|--------|
| Sheaf section template (7 strata questionnaire) | Done (TEMPLATE.md Section 13) |
| Per-stratum Lean type templates | Done (TEMPLATE.md Section 14) |
| Profunctor triad checklist | Done (TEMPLATE.md Section 10) |
| Completeness checklist | Done (TEMPLATE.md Section 13) |
| Lab-specific doc templates (AGENTS, DICT, TEMPLATE, TRACKER) | Pattern established (SystemLab, RL-Lab) |
| Git commit format | Done (TEMPLATE.md Section 9) |
| Justfile command naming | Done (TEMPLATE.md Section 7) |

**Verdict:** Mechanical lab instantiation is possible. Follow TEMPLATE.md Section 13.

---

## Inter-Lab Dependency Graph

```
PlatformLab                          SystemLab
-----------                          ---------
Types/IO/IODeployPhase/    ------->  Types/IO/IOPlatformPhase/
  (firmware images,                    (consumes platform
   board definitions)                   definitions for boot/hw)

SystemLab                            HomeLab
---------                            -------
Types/IO/IOUserPhase/      ------->  Types/IO/ (all phases)
  (user-level phases                   (dedicated user-level
   extracted to HomeLab)                artifact factory)

MaterialLab                          PlatformLab
-----------                          -----------
Types/Dependent/           ------->  Types/Dependent/
  (material properties                 (thermal/mechanical
   constrain schematics)                constraints)
```
