# Editor (FSC Abstract)

## FSC Definition

Editor is a category in FSC for text editor configurations and customizations.

### Types/Editor/
Type definitions for editor configurations:

Pure/ - Grounded types (owned by Editor category):
- Config/ - Editor configuration (keymaps, settings, theme)
  - Spaces/ + Bindings/ (grounded AttrSet)
- Plugins/ - Plugin specifications
  - Spaces/ + Bindings/ (grounded List)

Effects/ - Dependent types (external dependencies):
- Packages/ - Editor package and plugin packages
  - Spaces/ only (NO Bindings/ - free parameter)

### Monads/Editor/
Type constructors that produce editor artifacts:
- MonadFlake :: Monad<Flake> - Identity type (mandatory)
- MonadEditor :: Monad<Packages, Modules, Systems, Flake> - Produces editor config
  - Depends on MonadPackages (fundamental dependency)
  - Depends on MonadModules (configuration)
  - Depends on MonadSystems (deployment target)

Each Monad: Types/Editor/ -> Artifacts/Editor/<Target>/

Dependencies:
- Types/Editor/Pure/Config/ (grounded internally)
- Types/Editor/Pure/Plugins/ (grounded internally)
- Monads/Packages/MonadPackages/ (fundamental dependency)
- Monads/Modules/MonadModules/ (configuration)
- Monads/Systems/MonadSystems/ (deployment)

### Artifacts/Editor/
Type inhabitants - the actual editor outputs:
- Flake/flake.nix - Canonical editor flake
- Nvim/ - Neovim configuration
- Helix/ - Helix configuration
- Emacs/ - Emacs configuration

## Categorical Properties

1. Hard boundary - Editor/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Editor category maps to itself through Monads
4. Composable - Typically deployed via Home/ or Systems/

## Type-Theoretic Structure

```
Editor :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Monad<Packages, Modules, Systems, Flake>
    Artifacts :: Value
```

## Flow

```
Types/Editor/Pure/Config/Bindings/         # Editor config
Types/Editor/Pure/Plugins/Bindings/        # Plugin list
Types/Editor/Effects/Packages/Spaces/      # Package dependencies (NO Bindings/)
         ↓
Monads/Editor/MonadEditor/                 # Construct editor config
         ↓
Artifacts/Editor/Nvim/                     # Neovim configuration
```

## Pure vs Effects Invariant

Pure/ types:
- Have Spaces/ + Bindings/ (grounded within category)
- Example: Config/, Plugins/ owned by Editor

Effects/ types:
- Have Spaces/ only (NO Bindings/ - free parameters)
- Example: Packages/ is external dependency
- Grounded by MonadPackages

---

Last Updated: 2026-01-15
