# Package (FSC Abstract)

## FSC Definition

Package is a **core unit category** in FSC - every category depends on Packages.

### Types/Packages/
Pure type definitions for installable units:
- Source specifications (where code comes from)
- Build configurations (how to compile/assemble)
- Dependency declarations (what other packages are needed)
- Metadata (name, version, description)

Pure/ only - Packages are pure (no effects):
- Pure/ - Static package metadata and schemas
  - Spaces/ + Bindings/ (grounded)

### Monads/Packages/
Type constructors that produce package artifacts:
- MonadFlake :: Monad<Flake> - Identity type (mandatory)
- MonadPackages :: Monad<Flake> - Produces package derivations
  - Fundamental dependency for all categories

Each Monad: Types/Packages/ -> Artifacts/Packages/<Target>/

### Artifacts/Packages/
Type inhabitants - the actual built packages:
- Flake/flake.nix - Canonical package flake (outputs.packages)
- Nix/ - Nix store paths (/nix/store/<hash>-<name>)
- Rust/ - Compiled binaries (target/release/)
- Python/ - Wheels (.whl files)

## Categorical Properties

1. Core unit category - Every category depends on Packages
2. Hard boundary - Packages/ cannot import from other categories
3. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
4. Endofunctor - Package category maps to itself through Monads
5. Fundamental dependency - MonadPackages required by all categories

## Type-Theoretic Structure

```
Package :: CoreUnitCategory
  where
    Types     :: Pure
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

MonadPackages signature:
```
MonadPackages :: Monad<Flake>
MonadPackages = Types/Packages/ -> Artifacts/Packages/
```

## Flow

```
Types/Packages/Pure/Spaces/       # Package schema
Types/Packages/Pure/Bindings/     # Concrete package definitions
         ↓
Monads/Packages/MonadPackages/    # Construct packages
         ↓
Artifacts/Packages/Flake/         # Built package flake
```

## Universal Dependency

Every category depends on Packages:
```
MonadShell  :: Monad<Packages, Scripts, Flake>
MonadHome   :: Monad<Packages, Modules, Flake>
MonadSystem :: Monad<Packages, Modules, Services, Flake>
```

Packages is the fundamental unit of software.

---

Last Updated: 2026-01-15
