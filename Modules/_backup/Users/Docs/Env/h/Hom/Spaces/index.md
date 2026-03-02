# Hom

## Mathematical Object

Internal hom (exponential object) in a closed monoidal category

```lean
-- Internal hom definition
def Hom : Sh(X) → Sh(X) → Sh(X) :=
  fun A B => A ⟶ B  -- Internal hom object

-- Closed monoidal structure
class InternalHom (C : Category) [Monoidal C] where
  hom : C → C → C
  eval : ∀ A B, (hom A B) ⊗ A ⟶ B
  curry : ∀ {A B C}, (A ⊗ B ⟶ C) → (A ⟶ hom B C)
```

## Geometric Meaning

Vertical composition - transformations between structures.
"All ways to get from A to B."

Hom represents the space of morphisms, internalized as an object.

## Adjunction

```lean
-- Hom is RIGHT adjoint to Tensor (currying)
-- (─ ⊗ A) ⊣ Hom(A, ─)
theorem tensor_hom_adjunction (A : Sh X) :
  Adjunction (fun B => B ⊗ A) (fun C => Hom A C) where
  -- Currying isomorphism
  iso : Hom (B ⊗ A) C ≅ Hom B (Hom A C)
```

## Type Signature

```lean
def Hom.{u} : Sh.{u} X → Sh.{u} X → Sh.{u} X :=
  Bifunctor.mk
    (obj := fun (A, B) => A ⟶ B)
    (map := fun (φ, ψ) => fun f => ψ ∘ f ∘ φ)
```

## Composition Type

Hom is VERTICAL composition:
- Transforms between structures
- Function-like (A → B in Set)
- Encodes all possible transformations

## FSC Interpretation

In FSC, Hom represents:
- Function definitions
- Module transformations
- Type conversions
- `map`, `apply`, derivation builders

## Exponential Laws

```lean
-- Currying (tensor-hom adjunction)
theorem curry_uncurry (f : A ⊗ B ⟶ C) :
  uncurry (curry f) = f

theorem uncurry_curry (g : A ⟶ Hom B C) :
  curry (uncurry g) = g

-- Exponential identities
theorem hom_unit (A : Sh X) :
  Hom 𝟙 A ≅ A

theorem hom_tensor (A B C : Sh X) :
  Hom (A ⊗ B) C ≅ Hom A (Hom B C)
```

## Adjoint Partner

Tensor (⊗) - see [[Tensor]]

## Evaluation and Coevaluation

```lean
-- Evaluation: apply the function
def eval (A B : Sh X) : Hom A B ⊗ A ⟶ B :=
  fun (f, a) => f a

-- Coevaluation: create constant function
def coeval (A B : Sh X) : B ⟶ Hom A (A ⊗ B) :=
  fun b => fun a => (a, b)
```

## Nix Interpretation

```lean
-- Hom as function type
def HomNix (A B : Type) : Type :=
  A → B

-- Derivation builder
def mkDerivation : Hom InputSpec OutputSpec :=
  fun input => derivation { inherit input; builder = ...; }
```

## Composition Patterns

```lean
-- Vertical composition of transformations
def composeHom (f : Hom A B) (g : Hom B C) : Hom A C :=
  g ∘ f

-- Functor application
def fmap (F : Functor) (f : Hom A B) : Hom (F A) (F B) :=
  F.map f
```

## Relationship to Function Types

```lean
-- In Set: Hom(A, B) = A → B (function type)
-- In Sh(X): Hom(F, G) = sheaf of local morphisms
-- In Nix: Hom = lambda abstraction

-- The internal hom "internalizes" the external hom-set
theorem internal_external :
  Γ(Hom A B) ≅ Hom_C(A, B)
```
