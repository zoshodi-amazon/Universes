# Push (f_*)

## Mathematical Object

Pushforward functor along morphism f : X → Y

```lean
-- Sheaf-theoretic definition
def Push (f : X → Y) : Sh(X) → Sh(Y) :=
  fun F => fun U => F (f⁻¹ U)

-- The extension functor
class Pushforward (f : X → Y) where
  push : Sh X → Sh Y
  functorial : ∀ (g : F ⟶ G), push F ⟶ push G
```

## Geometric Meaning

Extension of structure from local space X to global space Y.
"How does my local change propagate to the global environment?"

Given f : X → Y, the pushforward f_* extends data on X to data on Y.

## Adjunction

```lean
-- Push is RIGHT adjoint to Pull
-- f^* ⊣ f_*
theorem pull_push_adjunction (f : X → Y) :
  Adjunction (Pull f) (Push f) where
  unit   : Id ⟶ Push f ∘ Pull f    -- η : local → global → local
  counit : Pull f ∘ Push f ⟶ Id    -- ε : global → local → global
```

## Type Signature

```lean
def Push.{u} (f : X → Y) : Sh.{u} X → Sh.{u} Y :=
  Functor.mk
    (obj := fun F => f_* F)
    (map := fun φ => f_* φ)
```

## Locality

Push is a LOCAL operation:
- Propagates local changes smoothly
- Continuous extension
- Preserves local structure

## FSC Interpretation

In FSC, Push (f_*) represents:
- Writing environment variables
- Updating configuration state
- Propagating local changes to global scope
- Flake output publication

## Composition Law

```lean
-- Covariant functoriality
theorem push_compose (f : X → Y) (g : Y → Z) :
  Push (g ∘ f) = Push g ∘ Push f

-- Identity preservation
theorem push_id : Push (id : X → X) = Id
```

## Adjoint Partner

Pull (f^*) - see [[Pull]]

## Unit and Counit

```lean
-- Unit: "embed local into global view of local"
def η (F : Sh X) : F ⟶ Pull f (Push f F)

-- Counit: "extract local from global extension"
def ε (G : Sh Y) : Push f (Pull f G) ⟶ G
```
