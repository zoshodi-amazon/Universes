# Type (FSC Abstract)

## FSC Definition

Type is the Level 1 directory in FSC where all type definitions reside, organized by category.

### Types/<Category>/
Type definitions for each category:
- Pure/ - Types without side effects
- Effects/ - Types with side effects
- Spaces/ - Abstract type classes, laws, defaults
- Bindings/ - Concrete type instances, overrides
- index.* - Composed type (Pure ⊕ Effects)

Spaces/Bindings duality exists only in Types/.

### Monads/<Category>/
Type constructors consume Types/ and produce Artifacts/:
- MonadFlake consumes Types/<Category>/
- Monad<Target> consumes Types/<Category>/

### Artifacts/<Category>/
Type inhabitants are evaluations of Types/ through Monads/:
- Each artifact is a type inhabitant
- Artifacts have no logic, only imports from Monads/

## Categorical Properties

1. Level 1 in type-theoretic hierarchy (Types)
2. Contains all type definitions across categories
3. Spaces/Bindings duality enforced
4. Pure/Effects separation optional
5. Consumed by Monads/, produces Artifacts/

## Type-Theoretic Structure

```
Types :: Category -> Type
Types category = Pure category ⊕ Effects category
  where
    Pure    :: Spaces ⊕ Bindings
    Effects :: Spaces ⊕ Bindings
```

Type hierarchy:
```
Level 3: Sorts      - Category boundaries (implicit)
Level 2: Kinds      - Type constructors (Monads/)
Level 1: Types      - Type definitions (Types/)  ← This level
Level 0: Values     - Type inhabitants (Artifacts/)
```

## Flow

```
Types/<Category>/Pure/Spaces/       # Abstract pure types
Types/<Category>/Pure/Bindings/     # Concrete pure types
Types/<Category>/Effects/Spaces/    # Abstract effect types
Types/<Category>/Effects/Bindings/  # Concrete effect types
         ↓
Types/<Category>/index.*            # Composed type
         ↓
Monads/<Category>/Monad<T>/         # Type constructor
         ↓
Artifacts/<Category>/<T>/           # Type inhabitant
```

## Spaces vs Bindings

Spaces/ - Abstract
- Type classes
- Laws and invariants
- Default values
- Interface contracts

Bindings/ - Concrete
- Type instances
- Overrides
- Implementations
- Concrete values

## Pure vs Effects

Pure/ - No side effects
- Data structures
- Pure functions
- Static configuration
- Schemas

Effects/ - Side effects
- I/O operations
- State mutations
- Process management
- Interactive scripts

---

Last Updated: 2026-01-15
