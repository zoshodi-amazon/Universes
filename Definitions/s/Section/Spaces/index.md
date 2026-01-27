# Section

## Mathematical Object

A section of a sheaf F over an open set U is an element of F(U).

```lean
-- Section = element of F(U)
def Section (F : Sheaf X) (U : Open X) : Type :=
  F.section U

-- Global section = section over entire space
def GlobalSection (F : Sheaf X) : Type :=
  F.section X

-- Notation: Γ(U, F) = F(U)
notation "Γ(" U ", " F ")" => Section F U
notation "Γ(" F ")" => GlobalSection F
```

## Geometric Meaning

Concrete data living over a context.
"What I can observe/access in this scope."

Sections are the "values" of a sheaf - the actual data at each context.

## FSC Interpretation

In FSC, a Section represents:
- Configuration value (data in a scope)
- Environment variable (value in context)
- Any scoped data access

```lean
-- Config as section
def Config (U : Scope) : Section ConfigSheaf U :=
  Γ(U, ConfigSheaf)

-- Reading env var = taking section
def getEnv (var : String) : Section EnvSheaf CurrentScope :=
  EnvSheaf.section CurrentScope var
```

## Restriction

```lean
-- Sections restrict to smaller opens
def restrict (h : U ⊆ V) (s : Γ(V, F)) : Γ(U, F) :=
  F.restrict h s

-- Notation: s|_U
notation s "|_" U => restrict (subset_of U) s
```

## Gluing

```lean
-- Compatible sections glue
def glue (cover : Cover U) (s : ∀ i, Γ(cover.set i, F))
    (compat : ∀ i j, s i |_(cover.set i ∩ cover.set j) = 
                     s j |_(cover.set i ∩ cover.set j)) :
    Γ(U, F) :=
  F.gluing cover s compat
```

## Global Sections Functor

```lean
-- Γ : Sh(X) → Set is a functor
def GlobalSectionsFunctor : Functor (Sh X) Set where
  obj F := Γ(F)
  map φ := φ.component X
```

## Relationship to 6FF

```lean
-- Pull creates sections: f^* G gives sections of G along f
-- Push extends sections: f_* F(V) = F(f⁻¹ V)

-- Global sections = Build output
-- Γ(X, F) is what f_! produces (complete artifact)
```

## Relationship to Other Concepts

- Sheaf: What sections belong to - see [[Sheaf]]
- Stalk: Germ of sections at a point - see [[Stalk]]
- Pull: Creates local sections - see [[Pull]]
