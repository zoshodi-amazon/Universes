# Flake (FSC Abstract)

## FSC Definition

A Flake is a special artifact type in FSC representing a Nix flake - the canonical output of every category.

### Types/<Category>/
Flake type definitions:
- Input schema (flake dependencies)
- Output schema (what flake produces)
- System specifications (supported platforms)

### Monads/<Category>/
MonadFlake is mandatory for every category:
- Consumes Types/<Category>/
- Produces Artifacts/<Category>/Flake/flake.nix
- Wires inputs to outputs

### Artifacts/<Category>/
Every category produces a Flake artifact:
- Flake/flake.nix - Canonical category flake
- Imports from Monads/<Category>/MonadFlake/

## Categorical Properties

1. Identity type - Every category must have MonadFlake
2. Mandatory artifact for every category
3. Produced by MonadFlake (mandatory monad)
4. Self-contained with explicit inputs
5. Hermetic builds (pure, reproducible)
6. Composable via flake inputs

## Type-Theoretic Structure

```
Flake :: CoreUnitCategory
Flake = {
  inputs  : AttrSet FlakeInput
  outputs : Inputs -> AttrSet Output
}
```

MonadFlake signature:
```
MonadFlake :: Monad<Flake>
MonadFlake = Types/<Category>/ -> Artifacts/<Category>/Flake/
```

Flake as identity:
```
Every Monad :: Monad<..., Flake>
```

Flake is always the last dependency in Monad type signatures.

## Flow

```
Types/<Category>/              # Flake type definition
         ↓
Monads/<Category>/MonadFlake/  # Construct flake
         ↓
Artifacts/<Category>/Flake/    # flake.nix artifact
```

## Flake Outputs by Category

Home:
```nix
outputs.homeModules.<name>
outputs.homeConfigurations.<name>
```

Packages:
```nix
outputs.packages.<system>.<name>
```

Shell:
```nix
outputs.devShells.<system>.<name>
```

Systems:
```nix
outputs.nixosConfigurations.<name>
outputs.darwinConfigurations.<name>
```

Modules:
```nix
outputs.nixosModules.<name>
outputs.darwinModules.<name>
```

## Universe Flake

MonadUniverse aggregates all categorical flakes:
```
Artifacts/Home/Flake/flake.nix
Artifacts/Packages/Flake/flake.nix
Artifacts/Shell/Flake/flake.nix
         ↓
Monads/Universe/MonadUniverse/
         ↓
Artifacts/Universe/Flake/flake.nix
         ↓
fsc/flake.nix (symlink)
```

## Flake Properties

1. Hermetic - All inputs explicit
2. Reproducible - Same inputs = same outputs
3. Composable - Flakes can depend on flakes
4. Lazy - Only evaluated when needed
5. Cached - Outputs cached by hash

---

Last Updated: 2026-01-15
