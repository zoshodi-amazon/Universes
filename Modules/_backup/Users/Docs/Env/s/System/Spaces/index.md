# System (FSC Abstract)

## FSC Definition

A System is a category in FSC characterized by its three canonical sum types representing complete operating system configurations.

### Types/Systems/
Type definitions for full system configurations:
- Hardware specifications (CPU, memory, disk)
- Boot configuration (bootloader, kernel parameters)
- Network configuration (interfaces, firewall, DNS)
- User management (users, groups, permissions)
- Service definitions (systemd units, launchd agents)

Optional Pure/Effects separation:
- Pure/ - Static system configuration (declarative state)
- Effects/ - System activation, service management, state changes

### Monads/Systems/
Type constructors that produce system artifacts:
- MonadFlake - Produces flake with nixosConfigurations/darwinConfigurations
- MonadNixOS - Produces NixOS system configuration
- MonadDarwin - Produces nix-darwin system configuration
- MonadISO - Produces bootable ISO image

Each Monad: Types/Systems/ -> Artifacts/Systems/<Target>/

### Artifacts/Systems/
Type inhabitants - the actual system outputs:
- Flake/flake.nix - Canonical system flake (outputs.nixosConfigurations, darwinConfigurations)
- NixOS/ - NixOS system closure (/nix/store/<hash>-nixos-system)
- Darwin/ - nix-darwin system closure
- ISO/ - Bootable ISO image

## Categorical Properties

1. Hard boundary - Systems/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - System category maps to itself through Monads
4. Composable - Systems import Modules/ via module system

## Type-Theoretic Structure

```
System :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

System as configuration:
```
System :: Config
System = {
  boot       : BootConfig
  networking : NetworkConfig
  users      : UserConfig
  services   : ServiceConfig
  modules    : [Module]
}
```

## Flow

```
Types/Systems/Pure/Spaces/       # System option definitions
Types/Systems/Pure/Bindings/     # Concrete system config
         ↓
Monads/Systems/MonadNixOS/       # Construct NixOS system
         ↓
Artifacts/Systems/NixOS/         # Built system closure
```

---

Last Updated: 2026-01-15
