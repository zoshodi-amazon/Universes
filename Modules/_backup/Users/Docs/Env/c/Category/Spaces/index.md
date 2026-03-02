# Category (FSC Abstract)

## FSC Definition

A Category is the fundamental organizational unit in FSC, representing an orthogonal universe with hard boundaries.

### Types/<Category>/
Type definitions for the category's domain:
- Pure types (data, functions, schemas)
- Effect types (I/O, state, processes)
- Spaces (abstract type classes, laws, defaults)
- Bindings (concrete type instances, overrides)

Optional Pure/Effects separation based on category needs.

### Monads/<Category>/
Type constructors that produce category artifacts:
- MonadFlake - Mandatory: produces canonical flake
- Monad<Target> - Optional: additional artifact targets

Each Monad: Types/<Category>/ -> Artifacts/<Category>/<Target>/

### Artifacts/<Category>/
Type inhabitants - the category's outputs:
- Flake/flake.nix - Mandatory: canonical category flake
- <Target>/ - Optional: additional artifact types

## Categorical Properties

1. Hard boundary - Categories cannot import from each other at Universe level
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Category maps to itself through Monads
4. Composable - Categories compose via flake inputs only
5. Orthogonal - Categories are parallel, independent universes

## Type-Theoretic Structure

```
Category :: Sort
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

Category as traced monoidal endofunctor:
```
Category :: * -> *
Category = Types ⊗ Monads ⊗ Artifacts
  where
    trace :: Types -> Monads -> Artifacts -> Types
```

## Canonical Categories

- Home - User environment configurations
- Packages - Installable software units
- Shell - Development environments
- Systems - Full OS configurations
- Modules - Reusable configuration units
- Services - Long-running processes
- Containers - Isolated environments
- Applications - User-facing programs
- Virtualization - Virtual machines
- Universe - Meta-category (aggregator)

## Flow

```
Types/<Category>/              # Define types
         ↓
Monads/<Category>/Monad<T>/    # Construct artifacts
         ↓
Artifacts/<Category>/<T>/      # Type inhabitants
```

## Invariants

1. Every category has MonadFlake
2. Every category produces Artifacts/<Category>/Flake/flake.nix
3. Categories are self-contained
4. Dependencies flow through flake inputs only
5. No cross-category imports at Universe level

---

Last Updated: 2026-01-15
