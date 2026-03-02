# Universe (FSC Abstract)

## FSC Definition

Universe is a meta-category in FSC that aggregates all categorical flakes into a single root flake.

### Types/Universe/
Type definitions for the universal aggregator:
- Category references (all categorical flakes)
- Input coordination (shared nixpkgs, follows)
- Output merging (combining all category outputs)
- System specifications (supported platforms)

Pure only - Universe has no effects:
- Pure/ - Aggregation schema and flake structure

### Monads/Universe/
Type constructors that produce universe artifacts:
- MonadUniverse - Aggregates all Artifacts/<Category>/Flake/ into single flake

Each Monad: Types/Universe/ -> Artifacts/Universe/Flake/

### Artifacts/Universe/
Type inhabitants - the root flake:
- Flake/flake.nix - Root flake aggregating all categories

## Categorical Properties

1. Meta-category - Universe aggregates other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Universe category maps to itself through Monads
4. Composable - Universe composes all categorical flakes

## Type-Theoretic Structure

```
Universe :: MetaCategory
  where
    Types     :: Pure
    Monads    :: [Category] -> Flake
    Artifacts :: RootFlake
```

Universe as aggregator:
```
Universe :: [Category] -> Flake
Universe categories = {
  inputs  = merge (map (.inputs) categories)
  outputs = merge (map (.outputs) categories)
}
```

## Flow

```
Artifacts/Home/Flake/flake.nix
Artifacts/Packages/Flake/flake.nix
Artifacts/Shell/Flake/flake.nix
Artifacts/Systems/Flake/flake.nix
         ↓
Types/Universe/Pure/Spaces/       # Aggregation schema
         ↓
Monads/Universe/MonadUniverse/    # Aggregate all flakes
         ↓
Artifacts/Universe/Flake/         # Root flake
         ↓
fsc/flake.nix (symlink)           # Entry point
```

## Special Properties

- Universe is the only meta-category
- MonadUniverse aggregates all MonadFlake outputs
- Root flake.nix is symlink to Artifacts/Universe/Flake/flake.nix
- Provides single entry point for entire FSC

---

Last Updated: 2026-01-15
