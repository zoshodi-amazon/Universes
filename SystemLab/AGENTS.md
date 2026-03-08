# AGENTS.md

This document extends `Universes/AGENTS.md` with SystemLab-specific rules.

For universal invariants, architecture, profunctor pattern, observation pipeline, 7 categories, coalgebraic dual, 6-functor formalism, import DAG, and anti-patterns, see the root `AGENTS.md`.

Pattern Version: v5.3.0 | Structure: FROZEN

---

## Domain Boundary

This lab configures **devices**. The domain is closed around: one human operator x N hardware deployment targets (laptop, desktop, phone, cyberdeck, VM, cloud instance). The end artifact is a complete, reproducible, type-checked configuration for any device.

Sub-projects (RL, fabrication, sovereignty) are **separate labs** with their own Types/CoTypes and domain-specific 7-phase chains. From this lab's perspective they are Identity types (opaque packages consumed as devShell inputs).

**"Done"** = every target device in the deployment table can be produced by `cata-build {target}` and fully observed by `ana-{phase} {target}`.

---

## Architecture

```
Types/ (Lean 4)  ->  default.json  ->  Types/IO/ (Nix)
7-category DSL       IO boundary       IO executors (builtins.fromJSON -> module API calls)

CoTypes/ (Lean 4) -- Coalgebraic dual of Types/ (1-1 correspondence)
```

---

## Phase Chain

```
Identity -> Platform -> Network -> Services -> User -> Workspace -> Deploy
(Unit/top)  (ADT)      (Indexed)   (A -> B)   (AxB)   (M A)        (IO)
```

7 phases. Each phase IS a type-theoretic category applied to the device configuration domain.

| # | Phase | Type Theory | Matter | Domain | Blowup Prevention |
|---|-------|-------------|--------|--------|-------------------|
| 1 | Identity | Unit (top) | BEC | Secrets, keys, Nix daemon, user account | Tight -- 3-5 dependent types max |
| 2 | Platform | Inductive (ADT) | Crystalline | Boot, disk, hardware, display, peripherals | New hardware = new Inductive variant, not new Dependent type |
| 3 | Network | Dependent (Indexed) | Liquid Crystal | Firewall, SSH, wireless, VPN, DNS | Fiber bundle over platform -- bounded by <=7 fields |
| 4 | Services | Hom (A -> B) | Liquid | Containers, daemons, databases | Thin for personal devices -- full server admin is a different domain |
| 5 | User | Product (A x B) | Gas | Shell, terminal, editor, browser, CLI tools | **Shallow** -- tool selections only, heavy configs are separate flakes consumed as Identity types |
| 6 | Workspace | Monad (M A) | Plasma | DevShells, language toolchains, build systems | **Shallow** -- base toolchains only, per-project envs live in project repos |
| 7 | Deploy | IO | QGP | homeConfigurations, nixosConfigurations, ISOs, VMs | Bounded by finite deployment target list |

---

## User Sub-Phases (7)

IOUserPhase (Product at top level) contains 7 sub-phases following the same category chain:

| # | Sub-Phase | Hom | Product |
|---|-----------|-----|---------|
| 1 | Identity | `Hom/User/Identity/` | `Product/User/Identity/` |
| 2 | Credentials | `Hom/User/Credentials/` | `Product/User/Credentials/` |
| 3 | Shell | `Hom/User/Shell/` | `Product/User/Shell/` |
| 4 | Terminal | `Hom/User/Terminal/` | `Product/User/Terminal/` |
| 5 | Editor | `Hom/User/Editor/` | `Product/User/Editor/` |
| 6 | Comms | `Hom/User/Comms/` | `Product/User/Comms/` |
| 7 | Packages | `Hom/User/Packages/` | `Product/User/Packages/` |

---

## Deployment Targets (Domain Closure)

The project is domain-complete when every row is producible and observable:

| Target | Platform | Format | cata- | ana- |
|--------|----------|--------|-------|------|
| MacBook (darwin) | aarch64-darwin | homeConfiguration | `cata-switch darwin` | `ana-{phase}` |
| Cloud dev box | x86_64-linux | homeConfiguration | `cata-switch cloud-dev` | `ana-{phase}` |
| NixOS workstation | x86_64-linux | nixosConfiguration | `cata-switch nixos` | `ana-{phase}` |
| Cyberdeck | x86_64-linux | ISO | `cata-build cyberdeck` | `ana-{phase}` |
| VM | x86_64-linux | VM image | `cata-build vm` | `ana-{phase}` |
| MicroVM | x86_64-linux | microvm | `cata-build microvm` | `ana-{phase}` |

---

## Justfile -> 6FF Mapping

| Recipe | Prefix | 6FF | Type/CoType |
|--------|--------|-----|-------------|
| `ana-check` | ana | f! (shriek pullback) | CoIO |
| `ana-show` | ana | f* (pullback) | CoProduct |
| `ana-eval {path}` | ana | f* (pullback) | CoProduct |
| `ana-keys {path}` | ana | Hom (internal) | CoInductive |
| `ana-identity` | ana | f* (pullback) | CoProduct/Identity |
| `ana-platform` | ana | f* (pullback) | CoProduct/Platform |
| `ana-network` | ana | f* (pullback) | CoProduct/Network |
| `ana-services` | ana | f* (pullback) | CoProduct/Services |
| `ana-user` | ana | f* (pullback) | CoProduct/User |
| `ana-workspace` | ana | f* (pullback) | CoProduct/Workspace |
| `ana-deploy` | ana | f* (pullback) | CoProduct/Deploy |
| `ana-types-validate` | ana | f! (shriek pullback) | CoHom |
| `ana-size {path}` | ana | f* (pullback) | CoIdentity |
| `ana-search {query}` | ana | f* (pullback) | CoInductive |
| `ana-info {pkg}` | ana | f* (pullback) | CoIdentity |
| `ana-repl` | ana | f* (pullback) | CoIO |
| `cata-types-build` | cata | f! (shriek push) | IO (Lake) |
| `cata-build {machine}` | cata | f! (shriek push) | Product/Deploy |
| `cata-switch {host}` | cata | f* (pushforward) | Product/Deploy |
| `cata-flash {m} {disk}` | cata | f* (pushforward) | Product/Deploy |
| `cata-update` | cata | f* (pushforward) | Identity (flake.lock) |
| `cata-gc {days}` | cata | f! (shriek push) | IO |
| `cata-optimize` | cata | f! (shriek push) | IO |
| `cata-sync-to {host}` | cata | f* (pushforward) | IO |
| `cata-ssh {machine}` | cata | f* (pushforward) | IO |
| `hylo-main {host}` | hylo | tensor | ana-types-validate x cata-switch |
| `hylo-remote-build` | hylo | tensor | cata-sync-to x cata-build |
| `hylo-remote-switch` | hylo | tensor | cata-sync-to x cata-switch |
| `hylo-dev {shell}` | hylo | tensor | ana-eval x cata-run |

---

## SystemLab-Specific Invariants

These extend the universal invariants in `Universes/AGENTS.md`:

1. One Lake project for all Lean types under Types/IO/ (`lakefile.lean`, `srcDir := "../.."`).
2. nixpkgs pinned to stable release (nixos-25.11). NO unstable.
3. User phase is shallow -- tool selections only. Heavy tool configs are separate flakes consumed as Identity types.
4. Workspace phase is shallow -- base toolchains only. Per-project envs live in project repos.
5. IO executors use `lib.recursiveUpdate` for local.json merge (Nix-specific merge pattern).

---

## SystemLab-Specific Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Pattern |
|-------------|---------------|-----------------|
| Heavy inline tool config in User phase | Blows up the phase | Extract to separate flake, consume as Identity type |
| Sub-project inside IOWorkspacePhase | Conflates domains | Separate lab with own Types/CoTypes |

---

## Toolchain

| Tool | Role |
|------|------|
| Lean 4 | Canonical types, compile-time checking, JSON export |
| Nix + flake-parts | Module system, derivation building, packaging |
| justfile | Morphism dispatcher -- ana-/cata-/hylo- classified commands |
| gum | Styled terminal output |
