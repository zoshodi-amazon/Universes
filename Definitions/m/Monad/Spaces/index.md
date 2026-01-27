# Monad (FSC Abstract)

## FSC Definition

Monad is the Level 2 directory in FSC where all type constructors reside, organized by category.

### Types/<Category>/
Monads consume type definitions from Types/:
- Pure types
- Effect types
- Composed types (Pure ⊕ Effects)

### Monads/<Category>/
Type constructors that transform types into artifacts:
- MonadFlake - Mandatory: produces canonical flake
- Monad<Target> - Optional: produces specific artifact types
- No Spaces/ - Monads are pure implementation (bindings only)
- No Bindings/ - Monads are the binding

Each Monad: Types/<Category>/ -> Artifacts/<Category>/<Target>/

### Artifacts/<Category>/
Monads produce type inhabitants in Artifacts/:
- Each Monad produces exactly one artifact type
- Artifacts import from Monads/ (no logic in Artifacts/)

## Categorical Properties

1. Level 2 in type-theoretic hierarchy (Kinds)
2. Type constructors (M :: Type -> Type)
3. No spaces/bindings duality (Monads are bindings)
4. All composition happens in Monads/
5. Produces Artifacts/, consumes Types/

## Type-Theoretic Structure

```
Monad :: Type -> Type
Monad<Target> :: Types/<Category>/ -> Artifacts/<Category>/<Target>/
```

Type hierarchy:
```
Level 3: Sorts      - Category boundaries (implicit)
Level 2: Kinds      - Type constructors (Monads/)  ← This level
Level 1: Types      - Type definitions (Types/)
Level 0: Values     - Type inhabitants (Artifacts/)
```

Monad as type constructor:
```
MonadFlake :: Category -> Flake
MonadFlake category = {
  inputs  = Types/<category>/Input/
  outputs = Types/<category>/Output/
}
```

## Flow

```
Types/<Category>/              # Type definitions
         ↓
Monads/<Category>/MonadFlake/  # Construct flake
         ↓
Artifacts/<Category>/Flake/    # Flake artifact
```

## Mandatory Monad

Every category must have MonadFlake:
```
Monads/<Category>/MonadFlake/index.nix
         ↓
Artifacts/<Category>/Flake/flake.nix
```

## Optional Monads

Categories can have additional Monads:
```
Monads/Home/MonadHome/     -> Artifacts/Home/Home/
Monads/Home/MonadOCI/      -> Artifacts/Home/OCI/
Monads/Packages/MonadNix/  -> Artifacts/Packages/Nix/
```

## Composition

Monads perform all composition:
- Import from Types/
- Apply type constructors
- Wire dependencies
- Produce Artifacts/

No type construction outside Monads/.

## MonadUniverse

Special meta-monad that aggregates all categorical flakes:
```
Monads/Universe/MonadUniverse/
         ↓
Artifacts/Universe/Flake/flake.nix
```

---

Last Updated: 2026-01-15
