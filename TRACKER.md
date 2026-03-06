# TRACKER.md

Implementation state for the Universes repository. Single source of truth for what exists, what's stubbed, and what's planned.

Pattern Version: v5.1.0 | Type: CoIO (observation of progress)

---

## Types/ (Algebraic — Production)

### Category 1: Identity (BEC — Unit/⊤)

| File | Status | Contents |
|------|--------|----------|
| `Types/Identity/Default.lean` | Done | Package, ProgramConfig, Phase |

### Category 2: Inductive (Crystalline — ADT/Sum)

| File | Status | Contents |
|------|--------|----------|
| `Types/Inductive/Default.lean` | Done | 15 ADTs: BootLoader, DisplayBackend, DisplayGreeter, ContainerBackend, GcInterval, SovereigntyMode, SearchEngine, AIProvider, MachineArch, MachineFormat, ShellEditor, TmuxPrefix, KittyTheme, Colorscheme, GitBranch, CloudOutputFormat |

### Category 3: Dependent (Liquid Crystal — Indexed)

| File | Status | Contents |
|------|--------|----------|
| `Types/Dependent/Default.lean` | Done | 14 structures: NixSettings, SopsConfig, BootConfig, DisplayConfig, NetworkConfig, SshConfig, ContainerConfig, SovereigntyConfig, GitConfig, BrowserConfig, AIConfig, CloudConfig, HomeTarget, HomeTargets, MachineConfig |

### Category 4: Hom (Liquid — A → B)

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

### Category 5: Product (Gas — A × B)

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

### Category 6: Monad (Plasma — M A)

| File | Status | Contents |
|------|--------|----------|
| `Types/Monad/Default.lean` | Done | PhaseError, BuildResult, SwitchResult, ValidationResult |

### Category 7: IO (QGP — Executors)

| Component | Status |
|-----------|--------|
| `Types/IO/lakefile.lean` | Done (48 lean_lib + 1 lean_exe) |
| `Types/IO/lean-toolchain` | Done (v4.16.0) |
| `Types/IO/Default.lean` | Partial (validates 5/7 phases — missing User, Deploy) |

| Phase | default.nix | default.json |
|-------|-------------|-------------|
| IOIdentityPhase | Done | Done |
| IOPlatformPhase | Done | Done |
| IONetworkPhase | Done | Done |
| IOServicesPhase | Done | Done |
| IOUserPhase | Done | Done (shared by sub-phases) |
| IOUserPhase/Monads/IOIdentityPhase | Done | — |
| IOUserPhase/Monads/IOCredentialsPhase | Done | — |
| IOUserPhase/Monads/IOShellPhase | Done | — |
| IOUserPhase/Monads/IOTerminalPhase | Done | — |
| IOUserPhase/Monads/IOEditorPhase | Done | — |
| IOUserPhase/Monads/IOCommsPhase | Done | — |
| IOUserPhase/Monads/IOPackagesPhase | Done | — |
| IOWorkspacePhase | Done | Done |
| IOMainPhase | Done | Done |

---

## CoTypes/ (Coalgebraic — Observation)

All 7 CoTypes categories exist as directory stubs with `Default.lean` files containing only comments and `import Lean.Data.Json`. None define actual structures, functions, or observation types. CoTypes are not registered in `lakefile.lean`.

### Current State

| # | Category | File | Status | Planned Contents |
|---|----------|------|--------|-----------------|
| 1 | CoIdentity | `CoTypes/CoIdentity/Default.lean` | Stub | Introspection witnesses: CoPackage, CoPhase (installed? present? reachable?) |
| 2 | CoInductive | `CoTypes/CoInductive/Default.lean` | Stub | Elimination forms: parsers, validators, exhaustiveness witnesses per ADT |
| 3 | CoDependent | `CoTypes/CoDependent/Default.lean` | Stub | Lifting validators: schema conformance, fiber inhabitation checks |
| 4 | CoHom | `CoTypes/CoHom/Default.lean` | Stub | Observation specs per phase (field-parallel to Hom/ with Bool/Option types) |
| 5 | CoProduct | `CoTypes/CoProduct/Default.lean` | Stub | Observation results per phase: Output (what was seen) + Meta (when/how) |
| 6 | Comonad | `CoTypes/Comonad/Default.lean` | Stub | ObservationTrace: extract (current) + extend (map over history) |
| 7 | CoIO | `CoTypes/CoIO/Default.lean` | Stub | Observer result types: ObservationResult per phase |

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

### CoHom Per-Phase (Planned)

| Phase | File | Status |
|-------|------|--------|
| Identity | `CoTypes/CoHom/Identity/Default.lean` | Not started |
| Platform | `CoTypes/CoHom/Platform/Default.lean` | Not started |
| Network | `CoTypes/CoHom/Network/Default.lean` | Not started |
| Services | `CoTypes/CoHom/Services/Default.lean` | Not started |
| User | `CoTypes/CoHom/User/Default.lean` | Not started |
| Workspace | `CoTypes/CoHom/Workspace/Default.lean` | Not started |
| Deploy | `CoTypes/CoHom/Deploy/Default.lean` | Not started |

### CoProduct Per-Phase (Planned)

| Phase | Output | Meta |
|-------|--------|------|
| Identity | Not started | Not started |
| Platform | Not started | Not started |
| Network | Not started | Not started |
| Services | Not started | Not started |
| User | Not started | Not started |
| Workspace | Not started | Not started |
| Deploy | Not started | Not started |

---

## Deployment Targets

| Target | Platform | Format | cata- producible? | ana- observable? |
|--------|----------|--------|-------------------|-----------------|
| MacBook (darwin) | aarch64-darwin | homeConfiguration | Yes | Partial (ad-hoc ana-* in justfile) |
| Cloud dev box | x86_64-linux | homeConfiguration | Yes | Partial |
| NixOS workstation | x86_64-linux | nixosConfiguration | Untested | Partial |
| Cyberdeck | x86_64-linux | ISO | Untested | Not started |
| VM | x86_64-linux | VM image | Untested | Not started |
| MicroVM | x86_64-linux | microvm | Untested | Not started |

---

## Infrastructure Gaps

| Gap | Category | Priority | Notes |
|-----|----------|----------|-------|
| Validation runner missing User + Deploy | IO | High | `Types/IO/Default.lean` validates 5/7 phases |
| All Product Meta are stubs | Product | Medium | Only `timestamp : String := ""` |
| CoTypes not in lakefile.lean | IO | High | No `lean_lib` entries for any CoTypes/ |
| CoIO Nix executors don't exist | CoIO | High | ana-* commands use ad-hoc nix eval, not typed observers |
| CoHom per-phase types don't exist | CoHom | High | No observation specification types |
| CoProduct per-phase types don't exist | CoProduct | High | No observation result types |
| Comonad trace type not defined | Comonad | Medium | No extract/extend observation history |

---

## Next Steps (Priority Order)

1. **CoIO + CoHom + CoProduct Lean types** — populate all 7 CoTypes with real structures across all 7 phases
2. **lakefile.lean registration** — add CoTypes lean_lib entries
3. **CoIO Nix executors** — typed observer scripts per phase
4. **Validation runner** — add User + Deploy to `Types/IO/Default.lean`
5. **Product Meta** — populate with real build metadata fields
6. **Justfile ana-* backing** — connect existing ana-* commands to CoIO executors
