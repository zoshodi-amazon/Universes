# Universes

Dendritic Nix configuration system.

**Pattern Version: v1.0.3** | **Structure: FROZEN**

---

## Overview

| Aspect | Description |
|--------|-------------|
| Pattern | Dendritic Nix (flake-parts + import-tree) |
| Philosophy | Capability-centric, not tool-centric |
| Structure | Two-level adjunction (Global ⊣ Local) |
| Language | Agnostic (Nix, Python, Rust, etc.) |

---

## Core Dualities

The pattern is built on two adjoint pairs:

### Global Duality (Module-level)

| Env | ⊣ | Instances |
|-----|---|-----------|
| Aggregates Options → ENV vars | | Consumes Env → Nix targets |
| Left adjoint (free) | | Right adjoint (forgetful) |

### Local Duality (Universe-level)

| Options | ⊣ | Bindings |
|---------|---|----------|
| Schema, types, constraints | | Runtime behavior, effects |
| Typeclass (interface) | | Instance (implementation) |

---

## Categorical Organization

```
Modules/
├── Computation/    # Process: interpreters, editors, services
├── Information/    # Symbol: code, docs, databases  
├── Physical/       # Matter: hardware, materials
└── Signal/         # Wave: audio, video, electrical
```

---

## Module Structure

Every module follows this frozen structure:

```
<Module>/
├── README.md           # Documentation (this template)
├── default.nix         # Tensor (empty, import-tree entry)
├── Env/                # Global: ENV var aggregation
├── Instances/          # Global: flake.modules.* exports
├── Drv/                # Optional: package reification
└── Universe/           # Local: feature microcosm
    └── <Feature>/
        ├── Options/    # Schema (default.nix ≅ index.<lang>)
        └── Bindings/   # Effects (Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins)
```

---

## Invariants

```
1. Every .nix file is a flake-parts module
2. Every Module has: README.md, default.nix, Env/, Instances/, Universe/
3. Every Universe/<Feature> has: Options/, Bindings/
4. Options/ is source of truth: default.nix ≅ index.<lang>
5. Bindings/ ⊆ {Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins}
6. Env/ aggregates Universe/*/Options → ENV vars
7. Instances/ exports to flake.modules.{homeManager,nixos,darwin,devShells}
8. NO manual imports (import-tree auto-imports)
9. File naming: default.* only
10. Standard scripting: Nushell (default.nu)
```

---

## Language Agnosticism

Options can be defined in any language:

| Language | File | Manifest |
|----------|------|----------|
| Nix | `default.nix` | — |
| Python | `index.py` | `pyproject.toml` |
| Rust | `index.rs` | `Cargo.toml` |
| TypeScript | `index.ts` | `package.json` |

The isomorphism:
```
Options/default.nix ≅ Options/index.<lang> ≅ ENV vars ≅ CLI flags
```

---

## Targets

| Target | Scope | Purpose |
|--------|-------|---------|
| `flake.modules.homeManager.*` | User | Home-manager modules |
| `flake.modules.nixos.*` | System | NixOS modules |
| `flake.modules.darwin.*` | System | nix-darwin modules |
| `perSystem.devShells.*` | Dev | Development environments |
| `perSystem.packages.*` | Build | Derivations |
| `perSystem.checks.*` | CI | Validation |

---

## Bindings Categories

| Category | Signature | Purpose |
|----------|-----------|---------|
| Scripts | `() → Effect` | Entry points (default.nu) |
| Commands | `Cmd → Effect` | CLI commands |
| Keymaps | `Key → Action` | Input bindings |
| Hooks | `Event → Effect` | Lifecycle (Init, Save, Load, Log, Sync, Cleanup) |
| State | `S → S` | State machines |
| Secrets | `Path → Value` | Sensitive data |
| Plugins | `Base → Extended` | Extensions |

---

## Modules

### Computation

| Module | Purpose | Targets |
|--------|---------|---------|
| [Browsers](Prelude/Modules/Computation/Browsers/) | Web browsing | homeManager |
| [Checks](Prelude/Modules/Computation/Checks/) | Linting, invariants | devShells, checks |
| [Editor](Prelude/Modules/Computation/Editor/) | Text editing | homeManager |
| [Home](Prelude/Modules/Computation/Home/) | Host configurations | homeConfigurations |
| [Network](Prelude/Modules/Computation/Network/) | Networking | homeManager |
| [Servers](Prelude/Modules/Computation/Servers/) | Containers | nixos |
| [Services](Prelude/Modules/Computation/Services/) | Long-running | devShells, packages |
| [Terminal](Prelude/Modules/Computation/Terminal/) | Shell, Tmux, Kitty | homeManager |
| [Virtualization](Prelude/Modules/Computation/Virtualization/) | VMs | nixos |

### Information

| Module | Purpose | Targets |
|--------|---------|---------|
| [Persist/Git](Prelude/Modules/Information/Persist/Git/) | Version control | homeManager |

---

## Usage

```bash
# Check all invariants
nix flake check

# Build darwin home configuration
nix build .#homeConfigurations.darwin.activationPackage

# Switch to configuration
home-manager switch --flake .#darwin

# Enter dev shell
nix develop .#checks
```

---

## Flake Integration

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } 
    (inputs.import-tree ./Modules);
}
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v1.0.3 | 2026-01-27 | README.md required, Nushell standard, file naming |
| v1.0.2 | 2026-01-27 | Plugins in Bindings/, 7 binding types |
| v1.0.1 | 2026-01-27 | default.nix naming |
| v1.0.0 | 2026-01-27 | Frozen structure, two-level adjunction |

---

**Pattern Version: v1.0.3** | **Structure: FROZEN** | **Expressiveness: Universe/**
