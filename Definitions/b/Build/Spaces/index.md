# Build (f_!)

## Mathematical Object

Proper pushforward (shriek pushforward) along morphism f : X → Y

```lean
-- Proper pushforward definition
def Build (f : X → Y) : Sh(X) → Sh(Y) :=
  fun F => f _! F  -- Shriek pushforward

-- The proper direct image functor
class ProperPushforward (f : X → Y) where
  build : Sh X → Sh Y
  functorial : ∀ (g : F ⟶ G), build F ⟶ build G
```

## Geometric Meaning

Global construction with compact support.
"Create a bounded, complete artifact from local structure."

Unlike Push (f_*) which extends smoothly, Build (f_!) constructs with finiteness guarantees.

## Adjunction

```lean
-- Build is LEFT adjoint to Load
-- f_! ⊣ f^!
theorem build_load_adjunction (f : X → Y) :
  Adjunction (Build f) (Load f) where
  unit   : Id ⟶ Load f ∘ Build f    -- η
  counit : Build f ∘ Load f ⟶ Id    -- ε
```

## Type Signature

```lean
def Build.{u} (f : X → Y) : Sh.{u} X → Sh.{u} Y :=
  Functor.mk
    (obj := fun F => f _! F)
    (map := fun φ => f _! φ)
```

## Globality

Build is a GLOBAL operation:
- Constructs complete, bounded artifacts
- Compact support (finite, terminating)
- Produces concrete outputs

## FSC Interpretation

In FSC, Build (f_!) represents:
- `nix build` (constructing derivations)
- Compilation (source → artifact)
- Package construction
- Flake outputs

## Composition Law

```lean
-- Covariant functoriality (like Push)
theorem build_compose (f : X → Y) (g : Y → Z) :
  Build (g ∘ f) = Build g ∘ Build f

-- Identity preservation
theorem build_id : Build (id : X → X) = Id
```

## Adjoint Partner

Load (f^!) - see [[Load]]

## Relationship to Push

```lean
-- Build vs Push: both are "direct image" but different
-- Push (f_*) : smooth extension (local)
-- Build (f_!) : proper pushforward (global)

-- When f is proper, they coincide
theorem proper_coincidence (f : X → Y) [Proper f] :
  Build f ≅ Push f
```

## Compact Support

```lean
-- Build produces compactly supported sections
-- "The artifact has finite, bounded extent"
def BuildCompact (f : X → Y) (F : Sh X) :
  CompactSupport (Build f F) :=
  ⟨finite_fibers f, bounded_sections F⟩
```

## Derivation Interpretation

```lean
-- In Nix terms, Build is derivation construction
structure Derivation where
  inputs  : List (Load f Input)   -- Dependencies loaded
  builder : Hom Input Output      -- Transformation
  output  : Build f Output        -- Constructed artifact
```
