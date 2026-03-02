# Sheaf

## Mathematical Object

A sheaf on a topological space X assigns data to open sets with coherent restriction and gluing.

```lean
-- Presheaf: contravariant functor from opens to types
structure Presheaf (X : TopSpace) where
  section : (U : Open X) → Type
  restrict : ∀ {U V}, U ⊆ V → section V → section U
  restrict_id : restrict (refl U) = id
  restrict_comp : restrict (h₁ ∘ h₂) = restrict h₂ ∘ restrict h₁

-- Sheaf: presheaf satisfying gluing axiom
structure Sheaf (X : TopSpace) extends Presheaf X where
  -- Locality: if sections agree on cover, they're equal
  locality : ∀ {U} (cover : Cover U) (s t : section U),
    (∀ i, restrict (cover.incl i) s = restrict (cover.incl i) t) → s = t
  
  -- Gluing: compatible local sections glue to global
  gluing : ∀ {U} (cover : Cover U) (s : ∀ i, section (cover.set i)),
    Compatible s → ∃! t : section U, ∀ i, restrict (cover.incl i) t = s i
```

## Geometric Meaning

Data that varies coherently over a space.
"What can I observe locally that patches together globally?"

A sheaf captures the idea that local data should be consistent and glueable.

## FSC Interpretation

In FSC, a Sheaf represents:
- FileType (data format varying over contexts)
- Configuration (local settings that compose)
- Any data with scope/context sensitivity

```lean
-- FileType as sheaf
def FileType : Sheaf Env where
  section U := Bytes U              -- Raw data in context U
  restrict := truncate              -- Restrict to smaller context
  locality := byte_equality         -- Bytes equal if locally equal
  gluing := concatenate             -- Compatible bytes glue
```

## Category of Sheaves

```lean
-- Sh(X) = category of sheaves on X
def Sh (X : TopSpace) : Category where
  Obj := Sheaf X
  Hom := SheafMorphism              -- Natural transformations
  id := SheafMorphism.id
  comp := SheafMorphism.comp
```

## 6FF Acts on Sh(X)

All six functors operate on the category of sheaves:

```lean
-- Given f : X → Y
def pull  (f : X → Y) : Sh Y → Sh X := f^*
def push  (f : X → Y) : Sh X → Sh Y := f_*
def load  (f : X → Y) : Sh Y → Sh X := f^!
def build (f : X → Y) : Sh X → Sh Y := f_!
def tensor : Sh X → Sh X → Sh X := (· ⊗ ·)
def hom : Sh X → Sh X → Sh X := Hom
```

## Examples

```lean
-- Constant sheaf (same data everywhere)
def ConstantSheaf (A : Type) : Sheaf X where
  section _ := A
  restrict _ := id

-- Skyscraper sheaf (data at single point)
def Skyscraper (x : X) (A : Type) : Sheaf X where
  section U := if x ∈ U then A else Unit

-- Structure sheaf (functions on space)
def StructureSheaf : Sheaf X where
  section U := U → R
  restrict h f := f ∘ h.incl
```

## Relationship to Other Concepts

- Section: Element of F(U) - see [[Section]]
- Stalk: Limit at a point - see [[Stalk]]
- Morphism: Natural transformation - see [[Morphism]]

## Adjoint Partner

Sheafification ⊣ Forgetful (Presheaf → Sheaf adjunction)
