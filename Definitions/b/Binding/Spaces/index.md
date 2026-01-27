# Binding (FSC Abstract)

## FSC Definition

Binding is a subdirectory within Types/ representing concrete type instances, overrides, and implementations.

### Types/<Category>/
Bindings exist within Types/ as concrete definitions:
- Pure/Bindings/ - Concrete pure type instances
- Effects/Bindings/ - Concrete effect handlers
- Duality with Spaces/ (concrete vs abstract)

### Monads/<Category>/
Monads consume both Spaces/ and Bindings/:
- Spaces provide interface contracts
- Bindings provide concrete implementations
- Monads compose them into Artifacts/

### Artifacts/<Category>/
Bindings are evaluated through Monads/ into Artifacts/:
- Bindings define "what actually is"
- Artifacts are "what gets built"

## Categorical Properties

1. Concrete implementations (type instances, overrides)
2. Tool-specific naming allowed
3. Implementation details
4. Exists only in Types/
5. Dual to Spaces/

## Type-Theoretic Structure

```
Binding :: Concrete
Binding = {
  typeInstance : TypeInstance
  overrides    : AttrSet Override
  impl         : Implementation
}
```

Spaces/Bindings duality:
```
Types/<Category>/<Pure|Effects>/
├── Spaces/    # Abstract (interface)
└── Bindings/  # Concrete (implementation)  ← This
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

Bindings/ contains:
- Config values (Nix modules)
- Type implementations (Haskell)
- Class implementations (OOP)
- Overrides (overlays)
- Concrete instances

Spaces/ contains:
- mkOption definitions (Nix modules)
- Type signatures (Haskell)
- Interface definitions (OOP)
- Default values
- Laws and invariants

## Relationship to Dictionary

In Dictionary/:
- Spaces/ = FSC abstract definition
- Bindings/ = Tool-specific interpretation

In Types/:
- Spaces/ = Abstract type class
- Bindings/ = Concrete type instance

Different meanings in different contexts.

## Invariant

Spaces/Bindings duality exists **only in Types/**.
Monads/ and Artifacts/ have no Spaces/Bindings.

---

Last Updated: 2026-01-15
