# Scripts (FSC Abstract)

## FSC Definition

Scripts is a category in FSC for imperative command automation and task runners.

### Types/Scripts/
Type definitions for imperative automation:

Pure/ - Grounded types (owned by Scripts category):
- Tasks/ - Task definitions and metadata
  - Spaces/ + Bindings/ (grounded AttrSet)

Effects/ - Dependent types (external dependencies):
- Packages/ - Required tools and utilities
  - Spaces/ only (NO Bindings/ - free parameter)

### Monads/Scripts/
Type constructors that produce script artifacts:
- MonadFlake :: Monad<Flake> - Identity type (mandatory)
- MonadScripts :: Monad<Packages, Modules, Systems, Flake> - Produces script runners
  - Depends on MonadPackages (fundamental dependency)
  - Depends on MonadModules (configuration)
  - Depends on MonadSystems (deployment target)

Each Monad: Types/Scripts/ -> Artifacts/Scripts/<Target>/

Dependencies:
- Types/Scripts/Pure/Tasks/ (grounded internally)
- Monads/Packages/MonadPackages/ (fundamental dependency)
- Monads/Modules/MonadModules/ (configuration)
- Monads/Systems/MonadSystems/ (deployment)

### Artifacts/Scripts/
Type inhabitants - the actual script outputs:
- Flake/flake.nix - Canonical scripts flake
- Just/ - Justfile task runner
- Bash/ - Bash scripts
- Make/ - Makefiles

## Categorical Properties

1. Hard boundary - Scripts/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Scripts category maps to itself through Monads
4. Minimal typing - Optimized for rapid iteration

## Type-Theoretic Structure

```
Scripts :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Monad<Packages, Modules, Systems, Flake>
    Artifacts :: Value
```

## Flow

```
Types/Scripts/Pure/Tasks/Bindings/         # Task definitions
Types/Scripts/Effects/Packages/Spaces/     # Package dependencies (NO Bindings/)
         ↓
Monads/Scripts/MonadScripts/               # Construct script runner
         ↓
Artifacts/Scripts/Just/                    # Justfile artifact
```

## Pure vs Effects Invariant

Pure/ types:
- Have Spaces/ + Bindings/ (grounded within category)
- Example: Tasks/ is owned by Scripts

Effects/ types:
- Have Spaces/ only (NO Bindings/ - free parameters)
- Example: Packages/ is external dependency
- Grounded by MonadPackages

---

Last Updated: 2026-01-15
