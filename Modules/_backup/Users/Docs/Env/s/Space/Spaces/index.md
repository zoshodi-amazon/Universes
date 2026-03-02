# Space (FSC Abstract)

## FSC Definition

Space is a subdirectory within Types/ representing abstract type classes, laws, and defaults.

### Types/<Category>/
Spaces exist within Types/ as abstract definitions:
- Pure/Spaces/ - Abstract pure type classes
- Effects/Spaces/ - Abstract effect signatures
- Duality with Bindings/ (abstract vs concrete)

### Monads/<Category>/
Monads consume both Spaces/ and Bindings/:
- Spaces provide interface contracts
- Bindings provide concrete implementations
- Monads compose them into Artifacts/

### Artifacts/<Category>/
Spaces are evaluated through Monads/ into Artifacts/:
- Spaces define "what should exist"
- Artifacts are "what actually exists"

## Categorical Properties

1. Abstract definitions (type classes, laws, defaults)
2. Tool-agnostic naming
3. Interface contracts
4. Exists only in Types/
5. Dual to Bindings/

## Type-Theoretic Structure

```
Space :: Abstract
Space = {
  typeClass : TypeClass
  laws      : [Law]
  defaults  : AttrSet Default
}
```

Spaces/Bindings duality:
```
Types/<Category>/<Pure|Effects>/
├── Spaces/    # Abstract (interface)
└── Bindings/  # Concrete (implementation)
```

## Flow

```
Types/<Category>/Pure/Spaces/       # Abstract type class
Types/<Category>/Pure/Bindings/     # Concrete type instance
         ↓
Monads/<Category>/Monad<T>/         # Compose abstract + concrete
         ↓
Artifacts/<Category>/<T>/           # Evaluated artifact
```

## Examples

Spaces/ contains:
- mkOption definitions (Nix modules)
- Type signatures (Haskell)
- Interface definitions (OOP)
- Default values
- Laws and invariants

Bindings/ contains:
- Config values (Nix modules)
- Type implementations (Haskell)
- Class implementations (OOP)
- Overrides
- Concrete instances

## Invariant

Spaces/Bindings duality exists **only in Types/**.
Monads/ and Artifacts/ have no Spaces/Bindings.

---

Last Updated: 2026-01-15
