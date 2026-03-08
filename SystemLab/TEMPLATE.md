# TEMPLATE.md

This document extends `Universes/TEMPLATE.md` with SystemLab-specific naming conventions.

For universal directory templates, filetype classification, justfile prefix classification, git commit format, and the profunctor pattern template, see the root `TEMPLATE.md`.

Pattern Version: v5.3.0 | Type: CoIO (observation of naming invariants)

---

## 1. The 7-Phase Chain (FROZEN)

```
Identity -> Platform -> Network -> Services -> User -> Workspace -> Deploy
(Unit)      (ADT)       (Indexed)  (A -> B)    (AxB)   (M A)        (IO)
```

### Phase Names (FROZEN)

| # | Phase | Category | What It Configures |
|---|-------|----------|--------------------|
| 1 | `Identity` | Unit | Secrets, keys, Nix daemon, user account |
| 2 | `Platform` | Inductive | Boot, disk, hardware, display, peripherals |
| 3 | `Network` | Dependent | Firewall, SSH, wireless, VPN, DNS |
| 4 | `Services` | Hom | Containers, daemons, databases |
| 5 | `User` | Product | Shell, terminal, editor, browser, CLI tools |
| 6 | `Workspace` | Monad | DevShells, language toolchains, build systems |
| 7 | `Deploy` | IO | homeConfigurations, nixosConfigurations, ISOs, VMs |

### User Sub-Phases (7, same category chain)

| # | Sub-Phase | What It Configures |
|---|-----------|-------------------|
| 1 | `Identity` | User account, home directory |
| 2 | `Credentials` | Git identity, SSH keys, tokens |
| 3 | `Shell` | Zsh, fish, nushell, direnv |
| 4 | `Terminal` | Tmux, kitty |
| 5 | `Editor` | Neovim (nixvim) |
| 6 | `Comms` | Browser, AI, cloud CLI, mail |
| 7 | `Packages` | Standalone packages list |

---

## 2. Directory Path Templates (SystemLab-specific)

### Types/ Paths

```
Types/Identity/{TypeName}/Default.lean            -- terminal objects
Types/Inductive/{VariantName}/Default.lean         -- ADT variants
Types/Dependent/{ConfigName}/Default.lean          -- indexed structures
Types/Hom/{Phase}/Default.lean                     -- phase input morphisms
Types/Hom/User/{SubPhase}/Default.lean             -- user sub-phase morphisms
Types/Product/{Phase}/Output/Default.lean           -- phase output
Types/Product/{Phase}/Meta/Default.lean             -- phase metadata
Types/Product/User/{SubPhase}/Output/Default.lean   -- user sub-phase output
Types/Product/User/{SubPhase}/Meta/Default.lean     -- user sub-phase meta
Types/Monad/{Effect}/Default.lean                   -- effect types
Types/IO/                                           -- Lake project root
Types/IO/IO{Phase}Phase/default.nix                 -- phase IO executor
Types/IO/IO{Phase}Phase/default.json                -- serialized Hom at boundary
Types/IO/IOUserPhase/Monads/IO{SubPhase}Phase/default.nix -- user sub-phase executor
```

### CoTypes/ Paths

```
CoTypes/CoIdentity/{CoTypeName}/Default.lean       -- introspection witnesses
CoTypes/CoInductive/{CoTypeName}/Default.lean       -- elimination forms
CoTypes/CoDependent/{CoTypeName}/Default.lean       -- cofibration validators
CoTypes/CoHom/{CoTypeName}/Default.lean             -- observation specifications
CoTypes/CoProduct/{CoTypeName}/Default.lean          -- observation results
CoTypes/Comonad/{CoTypeName}/Default.lean            -- observation traces
CoTypes/CoIO/{CoTypeName}/Default.lean               -- observer result types
CoTypes/CoIO/CoIO{Phase}Phase/default.nix            -- phase observer executor
```

### IO Executor Naming

| Phase | IO Executor Dir | CoIO Observer Dir |
|-------|----------------|-------------------|
| Identity | `IOIdentityPhase` | `CoIOIdentityPhase` |
| Platform | `IOPlatformPhase` | `CoIOPlatformPhase` |
| Network | `IONetworkPhase` | `CoIONetworkPhase` |
| Services | `IOServicesPhase` | `CoIOServicesPhase` |
| User | `IOUserPhase` | `CoIOUserPhase` |
| Workspace | `IOWorkspacePhase` | `CoIOWorkspacePhase` |
| Main (Deploy) | `IOMainPhase` | `CoIODeployPhase` |

---

## 3. Lean Module Paths

With `srcDir := "../.."` (lab root), Lean module paths mirror the filesystem:

```
import Types.Inductive.Default          -- Types/Inductive/Default.lean
import Types.Dependent.Default          -- Types/Dependent/Default.lean
import Types.Hom.Identity.Default       -- Types/Hom/Identity/Default.lean
import CoTypes.CoDependent.Default      -- CoTypes/CoDependent/Default.lean
import CoTypes.CoProduct.Default        -- CoTypes/CoProduct/Default.lean
```

### lakefile.lean Library Registration

Every `lean_lib` follows the naming pattern:

```lean
-- Types: category + phase name concatenated
lean_lib <<Identity>> where roots := #[`Types.Identity.Default]
lean_lib <<HomIdentity>> where roots := #[`Types.Hom.Identity.Default]
lean_lib <<ProductIdentityOutput>> where roots := #[`Types.Product.Identity.Output.Default]
lean_lib <<ProductIdentityMeta>> where roots := #[`Types.Product.Identity.Meta.Default]

-- CoTypes: Co-prefixed category name
lean_lib <<CoIdentity>> where roots := #[`CoTypes.CoIdentity.Default]
lean_lib <<CoHom>> where roots := #[`CoTypes.CoHom.Default]
```

---

## 4. Lean Structure Naming

### Types/ Structures

| Category | Pattern | Example |
|----------|---------|---------|
| Identity | `{Thing}` | `Package`, `ProgramConfig`, `Phase` |
| Inductive | `{VariantName}` (bare inductive) | `inductive BootLoader`, `inductive ShellEditor` |
| Dependent | `{ConfigName}` | `NixSettings`, `BootConfig`, `NetworkConfig` |
| Hom | `{Phase}Hom` | `IdentityHom`, `PlatformHom`, `UserShellHom` |
| Product Output | `{Phase}Output` | `IdentityOutput`, `PlatformOutput` |
| Product Meta | `{Phase}Meta` | `IdentityMeta`, `PlatformMeta` |
| Monad | `{Effect}` | `PhaseError`, `BuildResult`, `SwitchResult` |

### CoTypes/ Structures

| CoCategory | Pattern | Example |
|------------|---------|---------|
| CoIdentity | `Co{Thing}` | `CoPackage`, `CoProgramConfig`, `CoPhase` |
| CoInductive | `Co{Validator}` | `CoInductiveWitness`, `CoInductiveExhaustiveness` |
| CoDependent | `Co{ConfigName}` | `CoNixSettings`, `CoBootConfig`, `CoNetworkConfig` |
| CoHom | `Co{Phase}Hom` | `CoIdentityHom`, `CoPlatformHom`, `CoUserHom` |
| CoProduct Output | `Co{Phase}Output` | `CoIdentityOutput`, `CoPlatformOutput` |
| CoProduct Meta | `CoObservationMeta` | (shared across phases) |
| CoProduct Pair | `Co{Phase}Product` | `CoIdentityProduct` (observed + observation) |
| Comonad | `Observation{Thing}` | `ObservationEvent`, `ObservationTrace`, `ObservationError` |
| CoIO | `Observation{Thing}` | `ObservationResult`, `ObservationStatus`, `ObservationSummary` |

### Lean Field Naming Rules

- All fields are `camelCase`
- Boolean observation fields: `{thing}Observed`, `{thing}Valid`, `{thing}Present`, `{thing}Active`
- No `output` as a field name (reserved word in Lean 4.28+). Use `observed` for CoProduct pairs
- No `meta` as a standalone field name in structures containing other structures. Use `observation` for CoProduct pairs
- All structures derive `Repr, Lean.ToJson, Lean.FromJson`

---

## 5. Justfile Commands (SystemLab-specific)

```
ana-{phase}              -- Observe a specific phase
ana-user-{subphase}      -- Observe a user sub-phase
ana-types-validate       -- Validate Lean type schemas
ana-{verb} {arg}         -- General observation (eval, show, keys, search, info, size)
cata-{verb} {arg}        -- General production (build, switch, flash, update, gc, optimize)
cata-types-build         -- Build Lean type system
cata-sync-to {host}      -- Push repo to remote
cata-ssh {machine}       -- Connect to deployed target
hylo-main {host}         -- validate then switch (the event loop)
hylo-remote-{verb} {h}   -- Remote composite (build, switch, vm, microvm, install)
hylo-dev {shell}         -- Enter dev shell
```

---

## 6. Domain-Specific Names: WHERE They Live

| Domain Name Type | WHERE It Lives | Example |
|-----------------|----------------|---------|
| Hardware variants | `Types/Inductive/{Name}/Default.lean` | `BootLoader`, `MachineArch`, `HardwareProfile` |
| Tool choices | `Types/Inductive/{Name}/Default.lean` | `ShellEditor`, `KittyTheme`, `Colorscheme` |
| Provider names | `Types/Inductive/{Name}/Default.lean` | `AIProvider`, `SearchEngine` |
| Config parameters | `Types/Dependent/{Name}/Default.lean` | `NixSettings.maxJobs`, `SshConfig.forwardAgent` |
| Phase input values | `Types/Hom/{Phase}/Default.lean` | `IdentityHom.nixSettings` |
| Package names | `Types/IO/IO{Phase}Phase/default.nix` | `pkgs.neovim`, `pkgs.tmux` |
| Nix module paths | `Types/IO/IO{Phase}Phase/default.nix` | `programs.git.enable` |
| Deployment targets | `Types/Hom/Deploy/Default.lean` | `HomeTarget`, `MachineConfig` |
| Flake inputs | `flake.nix` | `nixpkgs`, `home-manager`, `nixvim` |
