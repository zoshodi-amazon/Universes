---
title: "Self-Hosted **Capability** _Spectrum_"
sub_title: Sovereignty through deterministic infrastructure
author: Universes
---

Why Self-Host?
===

> Own the stack. Own the data. Own the outcome.

<!-- pause -->

Three principles:

1. **Sovereignty** — no vendor can revoke your capability
2. **Privacy** — zero-knowledge by default, E2E where it matters
3. **Determinism** — same config always produces same system

<!-- pause -->

The cost of *not* self-hosting is ~~control~~ — you trade it for convenience.

<!-- speaker_note: This is the foundational argument. Every capability discussed flows from these three principles. Self-hosting is not about saving money, it is about owning your operational surface. -->

<!-- end_slide -->

The Stack
===

A single declarative pipeline from types to running services:

```nix
# Types define WHAT (vendor-agnostic)
options.servers.containers = {
  backend = lib.mkOption {
    type = lib.types.enum [ "podman" "arion" ];
    default = "podman";
    description = "Container backend";
  };
};
```

<!-- pause -->

```bash
# Monads produce HOW (effectful realization)
nix build .#sovereignty-toplevel   # build entire system
nix build .#sovereignty-vm         # bootable QEMU test
nix flake check                    # validate all types
```

<!-- pause -->

The output is **content-addressed** — identical inputs always produce identical `/nix/store` paths.

<!-- end_slide -->

Tier 1: Security
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

### Encrypted Collaboration

| Tool | Capability |
|------|-----------|
| **CryptPad** | E2E encrypted office suite |
| **sops-nix** | Declarative secrets management |
| **age** | Simple file encryption |

<!-- pause -->

The UN adopted CryptPad as their Google Docs replacement — <span style="color: #50fa7b">zero-knowledge by design</span>.

<!-- column: 1 -->

### Network Sovereignty

| Tool | Capability |
|------|-----------|
| **WireGuard** | Kernel-level mesh VPN |
| **Tailscale** | Zero-config WireGuard overlay |
| **Yggdrasil** | E2E encrypted IPv6 mesh |

<!-- pause -->

All in `nixpkgs`. All declarative. All self-hosted.

```nix
networking.wireguard.interfaces.wg0 = {
  privateKeyFile = config.sops.secrets.wg-key.path;
  listenPort = 51820;
};
```

<!-- speaker_note: CryptPad is the strongest option for collaborative docs. WireGuard is in the Linux kernel since 5.6 and is not a third-party tool anymore. -->

<!-- end_slide -->

Tier 2: Compute
===

Local LLM inference on commodity hardware:

| Model | Quant | Size | RAM | Quality |
|-------|-------|------|-----|---------|
| Llama 3.2 3B | Q4_K_M | 2 GB | 4 GB | Simple tasks |
| Mistral 7B | Q4_K_M | 4.4 GB | 8 GB | General purpose |
| Llama 3.1 8B | Q4_K_M | 4.9 GB | 8 GB | Best at 8B |
| Qwen 2.5 14B | Q4_K_M | 8.5 GB | 12 GB | Near GPT-3.5 |

<!-- pause -->

The runtime is trivial:

```bash
# Zero-install inference
nix-shell -p ollama --run "ollama run llama3.2"

# Or as a NixOS service
services.ollama.enable = true;
```

<!-- pause -->

Rule of thumb: **model GB + 3 GB headroom = RAM needed**.

Apple Silicon unified memory is the killer feature — GPU and CPU share the same pool.

<!-- end_slide -->

Tier 3: Services
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

### Data & Storage

- **Garage** — S3-compatible, distributed
- **Restic** — encrypted incremental backups
- **Syncthing** — P2P file sync, no server
- **Paperless-ngx** — document management

<!-- pause -->

### Development

- **Forgejo** — lightweight Git forge
- **Soft-serve** — TUI Git server
- **Zot** — OCI container registry

<!-- column: 1 -->

### Infrastructure

- **CoreDNS** — programmable DNS
- **Caddy** — auto-TLS reverse proxy
- **Uptime Kuma** — monitoring dashboard
- **Prometheus + Grafana** — metrics

<!-- pause -->

### Communication

- **Matrix/Synapse** — federated chat
- **Gotify** — push notifications
- **Neomutt** — TUI email client

<!-- speaker_note: Every tool listed is in nixpkgs. Podman containers plus NixOS services cover the full spectrum. Native NixOS modules for infra, containers for application services. -->

<!-- end_slide -->

Tier 4: Validation
===

Deterministic deployment in 4 steps — **no surprises**:

<!-- pause -->

```
Step 1: Type check          nix flake check
        ↓                   All options valid, no broken refs
Step 2: Build closure        nix build .#machine-toplevel
        ↓                   Every package, config, unit built
Step 3: VM test             nix build .#machine-vm
        ↓                   Boot locally, test interactively
Step 4: Integration         nix build .#checks.x86_64-linux.test-X
        ↓                   NixOS VM tests with assertions
```

<!-- pause -->

If all 4 pass, deployment is **content-addressed identical** everywhere.

The only delta at deploy time: runtime secrets + network state.

> Build = Validate. If it builds, it deploys.

<!-- end_slide -->

The TUI Workflow
===

A composable office suite from the terminal:

| Capability | Tool | Notes |
|------------|------|-------|
| Documents | `pandoc` + markdown | Export to pdf, docx, html |
| Spreadsheets | `sc-im` | Vim-like TUI spreadsheet |
| Presentations | `presenterm` | *You are looking at it* |
| PDF | `zathura` | Minimal viewer |
| Email | `neomutt` + `mbsync` | Full IMAP/SMTP |
| Calendar | `khal` + `vdirsyncer` | CalDAV sync |
| Tasks | `taskwarrior` | CLI task management |

<!-- pause -->

Every tool is in `nixpkgs`. Every tool is **composable**.

No Electron. No browser tabs. No subscriptions.

<!-- end_slide -->

The Generating Set
===

20 capabilities. 5 concerns. Full closure.

| Concern | Capabilities |
|---------|-------------|
| **Security** | CryptPad, sops-nix, age, WireGuard, Tailscale, Yggdrasil |
| **Compute** | ollama, llama.cpp, llamafile |
| **Services** | Forgejo, Garage, CoreDNS, Caddy, Matrix, Prometheus |
| **Data** | Restic, Syncthing, Paperless-ngx, Zot |
| **Workflow** | pandoc, sc-im, presenterm, neomutt, taskwarrior |

<!-- pause -->

All self-hosted. All in `nixpkgs`. All deterministic.

> The minimal orthogonal generating set that spans the full capability space.

<!-- speaker_note: Summary slide. You do not need 50 tools, you need the minimal set that covers all 5 concerns. Every tool here spans a capability no other tool in the set covers. -->
