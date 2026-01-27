# Artifact (FSC Abstract)

## FSC Definition

Artifact is the Level 0 directory in FSC where all type inhabitants (outputs) reside, organized by category.

### Types/<Category>/
Artifacts are evaluations of type definitions:
- Pure types evaluated to pure values
- Effect types evaluated to effectful values

### Monads/<Category>/
Artifacts are produced by type constructors:
- MonadFlake produces Artifacts/<Category>/Flake/
- Monad<Target> produces Artifacts/<Category>/<Target>/

### Artifacts/<Category>/
Type inhabitants - the actual outputs:
- Flake/flake.nix - Mandatory: canonical category flake
- <Target>/ - Optional: additional artifact types
- No logic - Only imports from Monads/
- Runtime files allowed (logs, generated files)

## Categorical Properties

1. Level 0 in type-theoretic hierarchy (Values)
2. Type inhabitants (v :: Type)
3. No spaces/bindings duality
4. No logic - Pure evaluation of Monads/
5. Final outputs of FSC flow

## Type-Theoretic Structure

```
Artifact :: Value
Artifact = eval (Monad Type)
```

Type hierarchy:
```
Level 3: Sorts      - Category boundaries (implicit)
Level 2: Kinds      - Type constructors (Monads/)
Level 1: Types      - Type definitions (Types/)
Level 0: Values     - Type inhabitants (Artifacts/)  ← This level
```

Artifact as evaluation:
```
Artifacts/<Category>/<Target>/index.* = 
  import ../../../Monads/<Category>/Monad<Target>/index.*
```

## Flow

```
Types/<Category>/              # Type definitions
         ↓
Monads/<Category>/Monad<T>/    # Type constructor
         ↓
Artifacts/<Category>/<T>/      # Type inhabitant (evaluation)
```

## Mandatory Artifact

Every category must have Flake artifact:
```
Artifacts/<Category>/Flake/flake.nix
```

This is produced by MonadFlake.

## Optional Artifacts

Categories can have additional artifacts:
```
Artifacts/Home/Home/index.nix       # home-manager module
Artifacts/Home/OCI/index.nix        # Container image
Artifacts/Packages/Nix/index.nix    # Nix derivation
```

## Artifact Types

Common artifact types:
- Flake - Nix flake (flake.nix)
- Derivation - Nix store path
- Module - Configuration function
- Container - OCI image
- ISO - Bootable image
- Binary - Compiled executable

## Runtime Files

Exception to index.* naming:
```
Artifacts/Logs/
├── 2026-01-15.log
├── 2026-01-16.log
└── ...
```

Runtime-generated files allowed in Artifacts/.

## Universe Artifact

Special root artifact:
```
Artifacts/Universe/Flake/flake.nix
         ↓
fsc/flake.nix (symlink)
```

Entry point for entire FSC.

---

Last Updated: 2026-01-15
