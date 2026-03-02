# Terminal (FSC Abstract)

## FSC Definition

Terminal is a category in FSC for terminal emulator configurations.

### Types/Terminal/
Type definitions for terminal configurations:

Pure/ - Grounded types (owned by Terminal category):
- Config/ - Terminal configuration (colors, fonts, keybindings)
  - Spaces/ + Bindings/ (grounded AttrSet)

Effects/ - Dependent types (external dependencies):
- Packages/ - Terminal emulator package
  - Spaces/ only (NO Bindings/ - free parameter)

### Monads/Terminal/
Type constructors that produce terminal artifacts:
- MonadFlake :: Monad<Flake> - Identity type (mandatory)
- MonadTerminal :: Monad<Packages, Modules, Systems, Flake> - Produces terminal config
  - Depends on MonadPackages (fundamental dependency)
  - Depends on MonadModules (configuration)
  - Depends on MonadSystems (deployment target)

Each Monad: Types/Terminal/ -> Artifacts/Terminal/<Target>/

Dependencies:
- Types/Terminal/Pure/Config/ (grounded internally)
- Monads/Packages/MonadPackages/ (fundamental dependency)
- Monads/Modules/MonadModules/ (configuration)
- Monads/Systems/MonadSystems/ (deployment)

### Artifacts/Terminal/
Type inhabitants - the actual terminal outputs:
- Flake/flake.nix - Canonical terminal flake
- Kitty/ - Kitty terminal configuration
- Alacritty/ - Alacritty configuration
- Wezterm/ - Wezterm configuration

## Categorical Properties

1. Hard boundary - Terminal/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Terminal category maps to itself through Monads
4. Composable - Typically deployed via Home/ or Systems/

## Type-Theoretic Structure

```
Terminal :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Monad<Packages, Modules, Systems, Flake>
    Artifacts :: Value
```

## Flow

```
Types/Terminal/Pure/Config/Bindings/       # Terminal config
Types/Terminal/Effects/Packages/Spaces/    # Package dependencies (NO Bindings/)
         ↓
Monads/Terminal/MonadTerminal/             # Construct terminal config
         ↓
Artifacts/Terminal/Kitty/                  # Kitty configuration
```

## Pure vs Effects Invariant

Pure/ types:
- Have Spaces/ + Bindings/ (grounded within category)
- Example: Config/ is owned by Terminal

Effects/ types:
- Have Spaces/ only (NO Bindings/ - free parameters)
- Example: Packages/ is external dependency
- Grounded by MonadPackages

---

Last Updated: 2026-01-15
