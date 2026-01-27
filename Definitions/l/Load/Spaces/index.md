# Load (f^!)

## Mathematical Object

Exceptional pullback (shriek pullback) along morphism f : X → Y

```lean
-- Exceptional pullback definition
def Load (f : X → Y) : Sh(Y) → Sh(X) :=
  fun F => f ^! F  -- Shriek pullback

-- The exceptional inverse image functor
class ExceptionalPullback (f : X → Y) where
  load : Sh Y → Sh X
  functorial : ∀ (g : F ⟶ G), load F ⟶ load G
```

## Geometric Meaning

Global import with compact support considerations.
"Bring the totality of external structure into my local context."

Unlike Pull (f^*) which restricts smoothly, Load (f^!) imports with boundary awareness.

## Adjunction

```lean
-- Load is RIGHT adjoint to Build
-- f_! ⊣ f^!
theorem build_load_adjunction (f : X → Y) :
  Adjunction (Build f) (Load f) where
  unit   : Id ⟶ Load f ∘ Build f    -- η
  counit : Build f ∘ Load f ⟶ Id    -- ε
```

## Type Signature

```lean
def Load.{u} (f : X → Y) : Sh.{u} Y → Sh.{u} X :=
  Functor.mk
    (obj := fun F => f ^! F)
    (map := fun φ => f ^! φ)
```

## Globality

Load is a GLOBAL operation:
- Imports complete external structures
- Respects compact support (bounded dependencies)
- Grounds existential capability space (Σ-type)

## FSC Interpretation

In FSC, Load (f^!) represents:
- Flake inputs (importing dependencies)
- Module imports
- Loading external packages
- Grounding the existential "there exists a dependency"

## Composition Law

```lean
-- Contravariant functoriality (like Pull)
theorem load_compose (f : X → Y) (g : Y → Z) :
  Load (g ∘ f) = Load f ∘ Load g

-- Identity preservation
theorem load_id : Load (id : X → X) = Id
```

## Adjoint Partner

Build (f_!) - see [[Build]]

## Relationship to Pull

```lean
-- Load vs Pull: both are "inverse image" but different
-- Pull (f^*) : smooth restriction (local)
-- Load (f^!) : exceptional pullback (global)

-- When f is proper, they coincide
theorem proper_coincidence (f : X → Y) [Proper f] :
  Load f ≅ Pull f
```

## Σ-Type Interpretation

```lean
-- Load grounds existential types
-- "There exists a module M such that..."
def LoadAsΣ (f : X → Y) (F : Sh Y) : Σ (x : X), F (f x) :=
  ⟨x, (Load f F).stalk x⟩
```
