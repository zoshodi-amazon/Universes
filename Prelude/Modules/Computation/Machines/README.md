# Machines

Machine fleet management and deployment.

**Pattern Version: v1.0.4** | **Structure: FROZEN**

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Computation / Machines |
| Purpose | Define and deploy NixOS machines |
| Targets | nixosConfigurations, Clan |

## Questions

| # | Question | Option Path | Type |
|---|----------|-------------|------|
| 1 | What is this machine called? | `identity.hostname` | `str` |
| 2 | What architecture? | `target.arch` | `x86_64 \| aarch64` |
| 3 | How do I deploy it? | `format.type` | `iso \| vm \| sd-image \| raw-efi \| oci` |
| 4 | What survives reboot? | `persistence.strategy` | `full \| impermanent \| ephemeral` |
| 5 | Where is persistent storage? | `persistence.device` | `str?` |

## Usage

```nix
machines.sovereignty = {
  identity.hostname = "sovereignty";
  target.arch = "x86_64";
  format.type = "iso";  # or "oci" for container deployment
  persistence.strategy = "impermanent";
  persistence.device = "/dev/disk/by-label/NIXOS_PERSIST";
};
```

## Bindings

| Option | Implementation |
|--------|----------------|
| `format.type = "iso"` | `system.build.isoImage` via Clan |
| `format.type = "oci"` | `nix2container.buildImage` |
| `persistence.strategy = "impermanent"` | `nix-community/impermanence` |

## Commands

```bash
just list                           # List all machines
just build sovereignty              # Build machine image
just flash sovereignty /dev/sda     # Flash to USB
just vm sovereignty                 # Run in VM
just remote-build-oci cloud-dev sovereignty  # Build OCI on remote
just load-oci sovereignty           # Load OCI into local podman
just run-oci sovereignty            # Run OCI container
```

## OCI Deployment

For platform-agnostic deployment, use `format.type = "oci"`:

```bash
# Build on Linux (remote)
just remote-build-oci cloud-dev sovereignty

# Load and run on Darwin
just load-oci sovereignty
just run-oci sovereignty
```

The OCI image contains the full nixosConfiguration, runnable anywhere via podman.
