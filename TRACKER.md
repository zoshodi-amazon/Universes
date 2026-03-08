# TRACKER.md

Cross-lab implementation dashboard for the Universes monorepo. Single source of truth for lab inventory, inter-lab dependencies, and universal invariant compliance.

Lab-specific TRACKER.md files extend this document with per-type implementation state.

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

## Phase Chains (per lab)

Each lab defines 7 domain-specific phases mapping to the universal type-theoretic categories:

| # | Category | SystemLab | HomeLab | MaterialLab | PlatformLab | RL-Lab |
|---|----------|-----------|---------|-------------|-------------|--------|
| 1 | Unit (top) | Identity | Identity | Discovery | Identity | Discovery |
| 2 | ADT / Sum | Platform | Credentials | Ingest | Schematic | Ingest |
| 3 | Indexed | Network | Shell | Geometry | Firmware | Feature |
| 4 | Hom (A->B) | Services | Terminal | Simulation | Toolchain | Train |
| 5 | Product (AxB) | User | Editor | Fabrication | Simulate | Eval |
| 6 | Monad (M A) | Workspace | Comms | Verify | Validate | Serve |
| 7 | IO | Deploy | Packages | Main | Deploy | Main |

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

---

## Universal Invariant Compliance

| Invariant | SystemLab | HomeLab | MaterialLab | PlatformLab | RL-Lab |
|-----------|-----------|---------|-------------|-------------|--------|
| Types/ + CoTypes/ only | Yes | Yes | Yes | Yes | Yes |
| 7 categories (1-1 dual) | Yes | Yes (scaffold) | Yes (scaffold) | Yes (scaffold) | Partial (4/7 CoTypes) |
| 1 type per file | Yes | Scaffold | Yes | Scaffold | Yes |
| IO/ capped at 7 | Yes (7) | Yes (7) | Yes (7) | Yes (7) | Yes (7+Validate) |
| default.json committed | Yes | Yes | Yes | Scaffold | Yes (all 9) |
| local.json pattern | Yes | Yes | Not yet | Not yet | Not yet |
| Justfile classified | Yes | Not yet | Not yet | Not yet | Not yet (bare names) |
| ana-/cata- duals | Partial | Not yet | Not yet | Not yet | Partial (2 observers) |
| CoIO observers | Not started | Not started | Not started | Not started | Done (Tail + Visualize) |

---

## Canonical Docs Status

| Doc | Universes/ | SystemLab/ | HomeLab/ | MaterialLab/ | PlatformLab/ | RL-Lab/ |
|-----|-----------|------------|----------|-------------|-------------|---------|
| README.md | Done | Done | Done | Done | Done | Done |
| AGENTS.md | Done | Done | Done | Done | Done | Done |
| DICTIONARY.md | Done | Done | Done | Done | Not yet | Done |
| TEMPLATE.md | Done | Done | Not yet | Done | Not yet | Not yet |
| TRACKER.md | Done (this file) | Done | Done | Done | Not yet | Done |
