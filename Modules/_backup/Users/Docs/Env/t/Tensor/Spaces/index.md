# Tensor (⊗)

## Mathematical Object

Monoidal product in a symmetric monoidal category

```lean
-- Tensor product definition
def Tensor : Sh(X) → Sh(X) → Sh(X) :=
  fun F G => F ⊗ G

-- Monoidal structure
class MonoidalProduct (C : Category) where
  tensor : C → C → C
  unit : C
  assoc : ∀ A B C, (A ⊗ B) ⊗ C ≅ A ⊗ (B ⊗ C)
  leftUnit : ∀ A, unit ⊗ A ≅ A
  rightUnit : ∀ A, A ⊗ unit ≅ A
```

## Geometric Meaning

Horizontal composition - combining structures side by side.
"A and B together, independently."

Tensor combines two objects without interaction, preserving their individual structure.

## Adjunction

```lean
-- Tensor is LEFT adjoint to Hom (currying)
-- (─ ⊗ A) ⊣ Hom(A, ─)
theorem tensor_hom_adjunction (A : Sh X) :
  Adjunction (fun B => B ⊗ A) (fun C => Hom A C) where
  -- Currying isomorphism
  iso : Hom (B ⊗ A) C ≅ Hom B (Hom A C)
```

## Type Signature

```lean
def Tensor.{u} : Sh.{u} X → Sh.{u} X → Sh.{u} X :=
  Bifunctor.mk
    (obj := fun (F, G) => F ⊗ G)
    (map := fun (φ, ψ) => φ ⊗ ψ)
```

## Composition Type

Tensor is HORIZONTAL composition:
- Combines independent structures
- Product-like (A × B in Set)
- No interaction between components

## FSC Interpretation

In FSC, Tensor (⊗) represents:
- Module composition (`imports = [A B C]`)
- Flake input combination
- Independent capability aggregation
- `mkShell { packages = [a b c]; }`

## Monoidal Laws

```lean
-- Associativity
theorem tensor_assoc (A B C : Sh X) :
  (A ⊗ B) ⊗ C ≅ A ⊗ (B ⊗ C)

-- Unit laws
theorem tensor_unit_left (A : Sh X) :
  𝟙 ⊗ A ≅ A

theorem tensor_unit_right (A : Sh X) :
  A ⊗ 𝟙 ≅ A

-- Symmetry (for symmetric monoidal)
theorem tensor_symm (A B : Sh X) :
  A ⊗ B ≅ B ⊗ A
```

## Adjoint Partner

Hom - see [[Hom]]

## Relationship to Product

```lean
-- In Set, Tensor is cartesian product
-- In Vect, Tensor is tensor product of vector spaces
-- In Sh(X), Tensor is sheaf tensor product

-- Tensor vs Product:
-- Product: universal property (projections)
-- Tensor: monoidal structure (may not have projections)
```

## Nix Interpretation

```lean
-- Tensor as attrset merge
def TensorNix (A B : AttrSet) : AttrSet :=
  A // B  -- Right-biased merge

-- Tensor as list concatenation
def TensorList (A B : List Package) : List Package :=
  A ++ B
```

## Composition Patterns

```lean
-- Horizontal composition of modules
def composeModules (M₁ M₂ : Module) : Module :=
  M₁ ⊗ M₂

-- Independent capability aggregation
def aggregateCapabilities (caps : List Capability) : Capability :=
  caps.foldl (· ⊗ ·) 𝟙
```
