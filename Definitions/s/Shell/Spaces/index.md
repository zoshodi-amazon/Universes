# Shell (FSC Abstract)

## FSC Definition

A Shell is a category in FSC characterized by its three canonical sum types representing development environments.

### Types/Shell/
Type definitions for interactive development environments:

Pure/ - Grounded types (owned by Shell category):
- Env/ - Environment variables (PATH, compiler flags)
  - Spaces/ + Bindings/ (grounded AttrSet)

Effects/ - Dependent types (external dependencies):
- Packages/ - Package dependencies (tools, libraries)
  - Spaces/ only (NO Bindings/ - free parameter)
- Scripts/ - Interactive scripts, justfiles, CLI tools
  - Spaces/ only (imperative, minimal typing)

### Monads/Shell/
Type constructors that produce shell artifacts:
- MonadFlake - Identity type (mandatory)
- MonadShell - Produces mkShell derivation
  - Depends on MonadPackages (external category)
  - Grounds Packages dependency

Each Monad: Types/Shell/ -> Artifacts/Shell/<Target>/

Dependencies:
- Types/Shell/Pure/Env/ (grounded internally)
- Monads/Packages/MonadPackages/ (external dependency)

### Artifacts/Shell/
Type inhabitants - the actual shell outputs:
- Flake/flake.nix - Canonical shell flake (outputs.devShells)
- Shell/ - mkShell derivation with environment

## Categorical Properties

1. Hard boundary - Shell/ cannot import from other categories at Universe level
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Shell category maps to itself through Monads
4. Composable - Shell can depend on Packages/ via flake inputs for testing

## Type-Theoretic Structure

```
Shell :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

Shell as environment:
```
Shell :: Environment
Shell = {
  packages   : [Package]
  env        : AttrSet String
  shellHook  : String
  scripts    : AttrSet Script
}
```

## Flow

```
Types/Shell/Pure/Env/Bindings/         # Grounded env vars
Types/Shell/Effects/Packages/Spaces/   # Package dependency (NO Bindings/)
         ↓
Monads/Shell/MonadShell/               # Grounds Packages via MonadPackages
         ↓
Artifacts/Shell/Flake/                 # Built mkShell environment
```

## Pure vs Effects Invariant

Pure/ types:
- Have Spaces/ + Bindings/ (grounded within category)
- Example: Env/ is owned by Shell

Effects/ types:
- Have Spaces/ only (NO Bindings/ - free parameters)
- Example: Packages/ is external dependency
- Grounded by external Monad (MonadPackages)

## Rapid Iteration

Shell category optimized for minimal typing:
- Loose typing for imperative commands
- Quick script testing without full module system
- Can depend on in-progress Packages/ for testing

---

Last Updated: 2026-01-15
