# DICTIONARY.md

This document extends `Universes/DICTIONARY.md` with SystemLab-specific terms.

For universal type-theoretic definitions (Algebra, Coalgebra, Catamorphism, Anamorphism, Hylomorphism, Profunctor, Adjunction, 6-Functor Formalism, etc.) and the CS/DevOps Rosetta Stone, see the root `DICTIONARY.md`.

Pattern Version: v5.3.0 | Type: CoIO (observation)

---

## HardwareProfile

**Formal:** An inductive type (ADT) classifying hardware into finite profiles. Each constructor drives automatic configuration of kernel modules, drivers, and services.

**Domain:** `Types/Inductive/HardwareProfile/Default.lean` -- `generic | laptop | desktop | server | vm`. The IO executor maps profiles to NixOS module configurations: laptop enables thermald, power management, fwupd; desktop enables GPU drivers, audio, bluetooth; vm uses minimal virtio modules.

**Directory:** `Types/Inductive/`

## HomeTarget

**Formal:** A dependent type (structure) parameterizing a home-manager deployment target. Indexed over machine architecture and format.

**Domain:** `Types/Dependent/` -- contains username, homeDirectory, machine arch, and deployment-specific parameters. The IO executor reads this to generate the correct `homeConfigurations.{name}` output.

**Directory:** `Types/Dependent/`

## MachineConfig

**Formal:** A dependent type (structure) parameterizing a NixOS/nix-darwin machine. Indexed over platform (HardwareProfile, MachineArch, MachineFormat).

**Domain:** `Types/Dependent/` -- contains hostname, system type, hardware profile, disk layout, and the dependent types that configure boot, display, network, services.

**Directory:** `Types/Dependent/`

## Phase (SystemLab-specific)

The 7-phase chain for device configuration:

| # | Phase | Type Theory | What It Configures |
|---|-------|-------------|--------------------|
| 1 | Identity | Unit (top) | Secrets, keys, Nix daemon, user account |
| 2 | Platform | Inductive (ADT) | Boot, disk, hardware, display, peripherals |
| 3 | Network | Dependent (Indexed) | Firewall, SSH, wireless, VPN, DNS |
| 4 | Services | Hom (A -> B) | Containers, daemons, databases |
| 5 | User | Product (A x B) | Shell, terminal, editor, browser, CLI tools |
| 6 | Workspace | Monad (M A) | DevShells, language toolchains, build systems |
| 7 | Deploy | IO | homeConfigurations, nixosConfigurations, ISOs, VMs |
