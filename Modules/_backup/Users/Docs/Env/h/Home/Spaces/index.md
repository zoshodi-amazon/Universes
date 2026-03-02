# Home (FSC Abstract)

## FSC Definition

A Home is a category in FSC characterized by its three canonical sum types representing user environment configurations.

### Types/Home/
Type definitions for user-level configurations:
- Package installations (user packages)
- Dotfile management (config files)
- Program configurations (editor, shell, terminal)
- Service management (user services)
- Environment variables (PATH, XDG dirs)

Optional Pure/Effects separation:
- Pure/ - Static user configuration (packages, dotfiles)
- Effects/ - User service activation, file operations

### Monads/Home/
Type constructors that produce home artifacts:
- MonadFlake - Produces flake with homeModules/homeConfigurations
- MonadHome - Produces home-manager configuration
- MonadOCI - Produces containerized home environment

Each Monad: Types/Home/ -> Artifacts/Home/<Target>/

### Artifacts/Home/
Type inhabitants - the actual home outputs:
- Flake/flake.nix - Canonical home flake (outputs.homeModules, homeConfigurations)
- Home/ - home-manager activation package
- OCI/ - Container image with user environment

## Categorical Properties

1. Hard boundary - Home/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Home category maps to itself through Monads
4. Composable - Home imports Modules/ via home-manager module system

## Type-Theoretic Structure

```
Home :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

Home as configuration:
```
Home :: Config
Home = {
  packages : [Package]
  programs : ProgramConfig
  services : ServiceConfig
  xdg      : XDGConfig
  home     : HomeConfig
}
```

## Flow

```
Types/Home/Pure/Spaces/       # Home option definitions (mkOption)
Types/Home/Pure/Bindings/     # Concrete home config values
         ↓
Monads/Home/MonadHome/        # Construct home-manager config
         ↓
Artifacts/Home/Home/          # Built home activation package
```

---

Last Updated: 2026-01-15
