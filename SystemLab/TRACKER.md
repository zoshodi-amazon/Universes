# TRACKER.md

This document extends `Universes/TRACKER.md` with SystemLab-specific implementation state.

For cross-lab dashboard, inter-lab dependencies, and universal invariant compliance, see the root `TRACKER.md`.

Pattern Version: v5.3.0 | Type: CoIO (observation of progress)

---

## Types/ (Algebraic -- Production)

### Category 1: Identity (BEC -- Unit/top)

| File | Status | Contents |
|------|--------|----------|
| `Types/Identity/Default.lean` | Done | Package, ProgramConfig, Phase |

### Category 2: Inductive (Crystalline -- ADT/Sum)

| File | Status | Contents |
|------|--------|----------|
| `Types/Inductive/Default.lean` | Done | 21 ADTs: BootLoader, DisplayBackend, DisplayGreeter, ContainerBackend, GcInterval, SovereigntyMode, SearchEngine, AIProvider, MachineArch, MachineFormat, ShellEditor, TmuxPrefix, KittyTheme, Colorscheme, GitBranch, CloudOutputFormat, DiskLayout, PersistenceStrategy, HardwareProfile, GpuDriver, AudioBackend |

### Category 3: Dependent (Liquid Crystal -- Indexed)

| File | Status | Contents |
|------|--------|----------|
| `Types/Dependent/Default.lean` | Done | 19 structures: NixSettings, SopsConfig, BootConfig, DisplayConfig, NetworkConfig, SshConfig, ContainerConfig, SovereigntyConfig, GitConfig, BrowserConfig, AIConfig, CloudConfig, HomeTarget, HomeTargets, MachineConfig, DiskConfig, PersistenceConfig, MachineUser, HardwareConfig |

### Category 4: Hom (Liquid -- A -> B)

| Phase | File | Status |
|-------|------|--------|
| Identity | `Types/Hom/Identity/Default.lean` | Done |
| Platform | `Types/Hom/Platform/Default.lean` | Done |
| Network | `Types/Hom/Network/Default.lean` | Done |
| Services | `Types/Hom/Services/Default.lean` | Done |
| User | `Types/Hom/User/Default.lean` | Done |
| User/Identity | `Types/Hom/User/Identity/Default.lean` | Done |
| User/Credentials | `Types/Hom/User/Credentials/Default.lean` | Done |
| User/Shell | `Types/Hom/User/Shell/Default.lean` | Done |
| User/Terminal | `Types/Hom/User/Terminal/Default.lean` | Done |
| User/Editor | `Types/Hom/User/Editor/Default.lean` | Done |
| User/Comms | `Types/Hom/User/Comms/Default.lean` | Done |
| User/Packages | `Types/Hom/User/Packages/Default.lean` | Done |
| Workspace | `Types/Hom/Workspace/Default.lean` | Done |
| Deploy | `Types/Hom/Deploy/Default.lean` | Done |

### Category 5: Product (Gas -- A x B)

| Phase | Output | Meta |
|-------|--------|------|
| Identity | Done | Stub (timestamp only) |
| Platform | Done | Stub |
| Network | Done | Stub |
| Services | Done | Stub |
| User | Done | Stub |
| User/Identity | Done | Stub |
| User/Credentials | Done | Stub |
| User/Shell | Done | Stub |
| User/Terminal | Done | Stub |
| User/Editor | Done | Stub |
| User/Comms | Done | Stub |
| User/Packages | Done | Stub |
| Workspace | Done | Stub |
| Deploy | Done | Stub |

### Category 6: Monad (Plasma -- M A)

| File | Status | Contents |
|------|--------|----------|
| `Types/Monad/Default.lean` | Done | PhaseError, BuildResult, SwitchResult, ValidationResult |

### Category 7: IO (QGP -- Executors)

| Component | Status |
|-----------|--------|
| `Types/IO/lakefile.lean` | Done (48 lean_lib Types + 7 lean_lib CoTypes + 1 lean_exe, srcDir=repo root) |
| `Types/IO/lean-toolchain` | Done (v4.16.0, runtime uses nix-provided 4.28.0) |
| `Types/IO/Default.lean` | Done (validates 5/7 phases -- imports all 7 Hom types) |

| Phase | default.nix | default.json | local.json |
|-------|-------------|-------------|------------|
| IOIdentityPhase | Done (local override) | Done | .gitignore'd |
| IOPlatformPhase | Done (local override) | Done | .gitignore'd |
| IONetworkPhase | Done (local override) | Done (sanitized) | .gitignore'd |
| IOServicesPhase | Done (local override) | Done | .gitignore'd |
| IOUserPhase | Done | Done (shared by sub-phases) | .gitignore'd |
| IOUserPhase/Monads/IOIdentityPhase | Done | -- | -- |
| IOUserPhase/Monads/IOCredentialsPhase | Done (local override) | -- | -- |
| IOUserPhase/Monads/IOShellPhase | Done (local override) | -- | -- |
| IOUserPhase/Monads/IOTerminalPhase | Done (local override) | -- | -- |
| IOUserPhase/Monads/IOEditorPhase | Done (local override) | -- | -- |
| IOUserPhase/Monads/IOCommsPhase | Done (local override) | -- | -- |
| IOUserPhase/Monads/IOPackagesPhase | Done (local override) | -- | -- |
| IOWorkspacePhase | Done (local override) | Done | .gitignore'd |
| IOMainPhase | Done (local override) | Done (sanitized) | .gitignore'd |

---

## CoTypes/ (Coalgebraic -- Observation)

All 7 CoTypes categories populated with real Lean 4 structures. Registered in lakefile.lean. All compile.

### Current State

| # | Category | File | Status | Contents |
|---|----------|------|--------|----------|
| 1 | CoIdentity | `CoTypes/CoIdentity/Default.lean` | Done | CoPackage, CoProgramConfig, CoPhase (installed? reachable? outputs present?) |
| 2 | CoInductive | `CoTypes/CoInductive/Default.lean` | Done | CoInductiveWitness, CoInductiveExhaustiveness, 21 validate* functions for all ADTs |
| 3 | CoDependent | `CoTypes/CoDependent/Default.lean` | Done | 18 Co* structures: CoNixSettings, CoSopsConfig, CoBootConfig, CoDisplayConfig, CoNetworkConfig, CoSshConfig, CoContainerConfig, CoSovereigntyConfig, CoGitConfig, CoBrowserConfig, CoAIConfig, CoCloudConfig, CoHomeTarget, CoMachineConfig, CoDiskConfig, CoPersistenceConfig, CoMachineUser, CoHardwareConfig |
| 4 | CoHom | `CoTypes/CoHom/Default.lean` | Done | 7 observation specs: CoIdentityHom, CoPlatformHom, CoNetworkHom, CoServicesHom, CoUserHom, CoWorkspaceHom, CoDeployHom (field-parallel to Hom/) |
| 5 | CoProduct | `CoTypes/CoProduct/Default.lean` | Done | 7 observation outputs (Co{Phase}Output), CoObservationMeta, 7 Co{Phase}Product pairs (observed + observation) |
| 6 | Comonad | `CoTypes/Comonad/Default.lean` | Done | ObservationEvent, ObservationTrace (extract + push), ObservationError, CoBuildResult, CoSwitchResult, CoValidationResult |
| 7 | CoIO | `CoTypes/CoIO/Default.lean` | Done | ObservationStatus (inductive: pass/fail/skip/error), ObservationResult, ObservationSummary |

### CoIO Nix Executors (Planned)

| Phase | CoIO Script | Status |
|-------|-------------|--------|
| CoIOIdentityPhase | `CoTypes/CoIO/CoIOIdentityPhase/default.nix` | Not started |
| CoIOPlatformPhase | `CoTypes/CoIO/CoIOPlatformPhase/default.nix` | Not started |
| CoIONetworkPhase | `CoTypes/CoIO/CoIONetworkPhase/default.nix` | Not started |
| CoIOServicesPhase | `CoTypes/CoIO/CoIOServicesPhase/default.nix` | Not started |
| CoIOUserPhase | `CoTypes/CoIO/CoIOUserPhase/default.nix` | Not started |
| CoIOWorkspacePhase | `CoTypes/CoIO/CoIOWorkspacePhase/default.nix` | Not started |
| CoIODeployPhase | `CoTypes/CoIO/CoIODeployPhase/default.nix` | Not started |

---

## Local Override Pattern (v5.3.0)

Machine-local data (credentials, corporate hostnames, passwords) is separated from universal types via `local.json` files.

| Component | Description |
|-----------|-------------|
| `default.json` | Identity (terminal object) -- canonical, committed, safe for git |
| `local.json` | Dependent (indexed over deployment site) -- machine-specific, .gitignore'd |
| `local.json.example` | Template for local overrides -- committed, shows expected shape |
| IO executor merge | `cfg = lib.recursiveUpdate base local` -- fiber bundle section |

---

## Deployment Targets

| Target | Platform | Format | homeConfig | nixosConfig | cata- producible? | ana- observable? |
|--------|----------|--------|------------|-------------|-------------------|-----------------|
| MacBook (darwin) | aarch64-darwin | homeConfiguration | `darwin` | -- | Yes | Partial (ad-hoc ana-* in justfile) |
| Cloud dev box | x86_64-linux | homeConfiguration | `cloud-dev` | -- | Yes | Partial |
| NixOS workstation | x86_64-linux | nixosConfiguration + homeConfiguration | `nixos` | `nixos-workstation` | Ready (untested) | Partial |
| Cyberdeck / Sovereignty | x86_64-linux | ISO | -- | `sovereignty` | Ready (untested) | Not started |
| Test VM | x86_64-linux | microvm | -- | `test-vm` | Ready (untested) | Not started |

---

## Infrastructure Gaps

| Gap | Category | Priority | Notes |
|-----|----------|----------|-------|
| Validation runner validates 5/7 phases | IO | Medium | User + Deploy JSON shapes don't match Lean Hom types yet |
| All Product Meta are stubs | Product | Medium | Only `timestamp : String := ""` |
| CoIO Nix executors don't exist | CoIO | High | ana-* commands use ad-hoc nix eval, not typed observers |
| lean-toolchain says 4.16.0, nix provides 4.28.0 | IO | Low | Works but version mismatch |

---

## Next Steps (Priority Order)

1. **CoIO Nix executors** -- typed observer scripts per phase (`CoTypes/CoIO/CoIO{Phase}Phase/default.nix`)
2. **Wire ana-* justfile commands** to CoIO executors (replace ad-hoc nix eval)
3. **Validation runner** -- align User + Deploy JSON to Lean Hom types for full 7/7 validation
4. **Product Meta** -- populate with real build metadata fields
5. **lean-toolchain** -- align with nix-provided Lean version
