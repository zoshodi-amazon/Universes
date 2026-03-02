# Morphism

## Mathematical Object

A morphism of sheaves is a natural transformation preserving the sheaf structure.

```lean
-- Sheaf morphism = natural transformation
structure SheafMorphism (F G : Sheaf X) where
  component : ∀ (U : Open X), F.section U → G.section U
  naturality : ∀ {U V} (h : U ⊆ V),
    component U ∘ F.restrict h = G.restrict h ∘ component V
```

## Geometric Meaning

Structure-preserving transformation between sheaves.
"A way to transform data that respects locality and gluing."

Morphisms are the arrows in Sh(X) - they encode how data transforms coherently.

## FSC Interpretation

In FSC, a Morphism represents:
- Codec (encode/decode between formats)
- Transformation (data conversion)
- Any structure-preserving map

```lean
-- Codec as sheaf morphism
def Codec (F G : Sheaf Env) : Type :=
  SheafMorphism F G

-- JSON to YAML codec
def jsonToYaml : Codec JsonSheaf YamlSheaf where
  component U := parseJson U ∘ emitYaml U
  naturality := by simp [restrict_parse, restrict_emit]
```

## Composition

```lean
-- Morphisms compose
def comp (f : SheafMorphism F G) (g : SheafMorphism G H) : SheafMorphism F H where
  component U := g.component U ∘ f.component U
  naturality := by simp [f.naturality, g.naturality]

-- Identity morphism
def id (F : Sheaf X) : SheafMorphism F F where
  component _ := id
  naturality := by simp
```

## Isomorphism

```lean
-- Isomorphism = morphism with inverse
structure SheafIso (F G : Sheaf X) where
  to : SheafMorphism F G
  inv : SheafMorphism G F
  to_inv : comp to inv = id F
  inv_to : comp inv to = id G
```

## Pull-Push Adjunction

Morphisms encode the codec adjunction:

```lean
-- f^* ⊣ f_* gives bijection on morphisms
theorem pull_push_hom (f : X → Y) (F : Sheaf X) (G : Sheaf Y) :
  SheafMorphism (f^* G) F ≅ SheafMorphism G (f_* F)
```

## Kernel and Cokernel

```lean
-- Exact sequences of sheaves
def Kernel (φ : SheafMorphism F G) : Sheaf X where
  section U := { s : F.section U | φ.component U s = 0 }

def Image (φ : SheafMorphism F G) : Sheaf X where
  section U := { t : G.section U | ∃ s, φ.component U s = t }
```

## Relationship to Other Concepts

- Sheaf: Domain and codomain - see [[Sheaf]]
- Section: What morphisms act on - see [[Section]]
- Hom: Internal hom of morphisms - see [[Hom]]
