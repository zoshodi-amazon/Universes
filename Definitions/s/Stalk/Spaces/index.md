# Stalk

## Mathematical Object

The stalk of a sheaf F at a point x is the colimit of sections over all neighborhoods of x.

```lean
-- Stalk = colimit over neighborhoods
def Stalk (F : Sheaf X) (x : X) : Type :=
  colimit (fun U : { U : Open X // x ∈ U } => F.section U)

-- Equivalently: germs of sections at x
def Stalk' (F : Sheaf X) (x : X) : Type :=
  Σ (U : Open X) (h : x ∈ U), F.section U / ~
  where
    (U, h, s) ~ (V, k, t) ↔ ∃ W ⊆ U ∩ V, x ∈ W ∧ s|_W = t|_W
```

## Geometric Meaning

Infinitesimal data at a point - what you see "right here".
"The germ of information at this exact location."

Stalks capture local behavior at a point, forgetting global structure.

## FSC Interpretation

In FSC, a Stalk represents:
- Secret (data at a specific point, not spread over context)
- Local state (value at exact location)
- Point-specific data

```lean
-- Secret as stalk
def Secret (x : Point) : Stalk SecretSheaf x :=
  -- The secret value at exactly this point
  -- Not visible from any other location

-- Stalk captures "need to know" - only accessible at x
```

## Stalk Functor

```lean
-- Taking stalks is a functor
def StalkFunctor (x : X) : Functor (Sh X) Set where
  obj F := Stalk F x
  map φ := fun [s] => [φ.component _ s]  -- Well-defined on germs
```

## Sheaf Condition via Stalks

```lean
-- A presheaf is a sheaf iff it's determined by stalks
theorem sheaf_iff_stalks (F : Presheaf X) :
  IsSheaf F ↔ ∀ U s t, (∀ x ∈ U, germ x s = germ x t) → s = t
```

## Pullback and Stalks

```lean
-- Key property: pullback preserves stalks
theorem pull_stalk (f : X → Y) (G : Sheaf Y) (x : X) :
  Stalk (f^* G) x ≅ Stalk G (f x)

-- "What I see locally = what's there globally, restricted to my point"
```

## Skyscraper Sheaf

```lean
-- Skyscraper: all data concentrated at one point
def Skyscraper (x : X) (A : Type) : Sheaf X where
  section U := if x ∈ U then A else Unit
  
-- Stalk of skyscraper
theorem skyscraper_stalk (y : X) :
  Stalk (Skyscraper x A) y = if y = x then A else Unit
```

## Relationship to Other Concepts

- Sheaf: What stalks are taken of - see [[Sheaf]]
- Section: Stalks are germs of sections - see [[Section]]
- Pull: Preserves stalks - see [[Pull]]
