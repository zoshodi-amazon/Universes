# Pull (f^*)

## Mathematical Object

Pullback functor along morphism f : X → Y

```lean
-- Sheaf-theoretic definition
def Pull (f : X → Y) : Sh(Y) → Sh(X) :=
  fun F => F ∘ f

-- The restriction functor
class Pullback (f : X → Y) where
  pull : Sh Y → Sh X
  functorial : ∀ (g : F ⟶ G), pull F ⟶ pull G
```

## Geometric Meaning

Restriction of structure from global space Y to local space X.
"What does the environment look like from my local perspective?"

Given f : X → Y, the pullback f^* restricts data on Y to data on X.

## Adjunction

```lean
-- Pull is LEFT adjoint to Push
-- f^* ⊣ f_*
theorem pull_push_adjunction (f : X → Y) :
  Adjunction (Pull f) (Push f) where
  unit   : Id ⟶ Push f ∘ Pull f    -- η
  counit : Pull f ∘ Push f ⟶ Id    -- ε
```

## Type Signature

```lean
def Pull.{u} (f : X → Y) : Sh.{u} Y → Sh.{u} X :=
  Functor.mk
    (obj := fun F => f ^* F)
    (map := fun φ => f ^* φ)
```

## Locality

Pull is a LOCAL operation:
- Operates on open neighborhoods
- Preserves stalks: (f^* F)_x ≅ F_{f(x)}
- Smooth/continuous restriction

## FSC Interpretation

In FSC, Pull (f^*) represents:
- Reading environment variables
- Accessing configuration values
- Restricting global state to local scope
- Flake input access

## Composition Law

```lean
-- Contravariant functoriality
theorem pull_compose (f : X → Y) (g : Y → Z) :
  Pull (g ∘ f) = Pull f ∘ Pull g

-- Identity preservation
theorem pull_id : Pull (id : X → X) = Id
```

## Adjoint Partner

Push (f_*) - see [[Push]]
