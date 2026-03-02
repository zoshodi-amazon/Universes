# SpectralSequence

## Mathematical Object

A spectral sequence is a sequence of pages computing homology through successive approximations.

```lean
-- Spectral sequence: pages with differentials
structure SpectralSequence where
  E : ℕ → BiGradedModule           -- E_r^{p,q} for each page r
  d : ∀ r, E r → E r               -- Differential d_r
  d_sq : ∀ r, d r ∘ d r = 0        -- d² = 0
  H : E (r + 1) ≅ Homology (E r) (d r)  -- Next page = homology

-- Convergence
def converges (E : SpectralSequence) (H : GradedModule) : Prop :=
  ∃ r₀, ∀ r ≥ r₀, E r ≅ E r₀ ∧ GrAssoc (E r₀) H
```

## Geometric Meaning

Filtration-based computation revealing structure layer by layer.
"Peel back layers of complexity to reveal underlying structure."

Each page E_r captures information at filtration level r. Differentials d_r reveal relations.

## FSC Interpretation

In FSC, a SpectralSequence represents:
- Reverse engineering (successive approximation to structure)
- Information filtration (layers of abstraction)
- Pipeline stages (each stage refines understanding)

```lean
-- Reverse engineering as spectral sequence
def reverseEngineer (binary : Bytes) : SpectralSequence where
  E 0 := RawBytes binary           -- Page 0: raw data
  E 1 := ParsedSections binary     -- Page 1: sections
  E 2 := SymbolTable binary        -- Page 2: symbols
  E 3 := ControlFlowGraph binary   -- Page 3: CFG
  E 4 := AbstractStructure binary  -- Page 4: high-level
  d r := extractRelations r        -- Differential reveals structure
```

## The Differential

```lean
-- d_r : E_r^{p,q} → E_r^{p+r, q-r+1}
-- Differential "moves" through the bigrading

-- d_r reveals relations invisible at level r-1
-- Homology H(E_r, d_r) = "what survives" to next page
```

## Convergence

```lean
-- E_∞ = stable page (no more differentials)
def E_infinity (E : SpectralSequence) : BiGradedModule :=
  limit (fun r => E r)

-- Converges to H means E_∞ computes H
-- "Final answer after all filtration levels processed"
```

## Leray Spectral Sequence

```lean
-- For f : X → Y, computes pushforward cohomology
-- E_2^{p,q} = H^p(Y, R^q f_* F) ⟹ H^{p+q}(X, F)

def LeraySpectralSequence (f : X → Y) (F : Sheaf X) : SpectralSequence where
  E 2 := fun p q => H^p(Y, R^q (f_*) F)
  -- Converges to H^*(X, F)
```

## Grothendieck Spectral Sequence

```lean
-- For composed functors G ∘ F
-- E_2^{p,q} = R^p G (R^q F A) ⟹ R^{p+q} (G ∘ F) A

def GrothendieckSS (F : C → D) (G : D → E) : SpectralSequence where
  E 2 := fun p q => (R^p G) ((R^q F) A)
  -- Converges to R^*(G ∘ F) A
```

## Relationship to 6FF

```lean
-- Derived functors of 6FF computed via spectral sequences
-- R f_* : derived pushforward
-- R f_! : derived proper pushforward
-- R Hom : Ext groups

-- Spectral sequences compute these derived functors
```

## Relationship to Other Concepts

- Sheaf: What spectral sequences compute cohomology of - see [[Sheaf]]
- Morphism: Differentials are morphisms - see [[Morphism]]
- Build: f_! cohomology via spectral sequence - see [[Build]]
