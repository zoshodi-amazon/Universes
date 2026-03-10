# CoStratum 2 — CoInductive (Crystalline Dual, Cofree)

## Lean 4 Template

```lean
-- CoStratum 2: CoInductive (Crystalline dual, cofree)
-- Lean keyword: structure (elimination witness, all Bool fields)
-- Duality: Inductive (free/constructors) ↔ CoInductive (cofree/eliminators)
-- Where Inductive defines constructors, CoInductive exercises elimination forms.

structure Co{Name}Inductive where
  {fields : Bool := false}    -- schema conformance probes
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Duality & Closure

**Dual of:** Stratum 2 (Inductive, sum types / ADTs).

Where `FrameInductive` defines the constructors for valid OHLCV data (5 float arrays with `from_dataframe`), `CoFrameInductive` exercises the elimination form — "given runtime data, can we successfully destruct it into a valid Frame?" Each Bool field witnesses one aspect of schema conformance.

**Pattern:** All fields are `Bool`, defaulting to `False`. The CoIO observer probes actual runtime artifacts and flips fields to `True` as conformance checks pass. A fully-`True` CoInductive means the data faithfully inhabits the Inductive type.

## Implemented Types

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `CoFrameInductive` | 4 | `FrameInductive` | `CoTypes/CoInductive/Frame/default.py` |
| `CoCatalogInductive` | 2 | `CatalogInductive` | `CoTypes/CoInductive/Catalog/default.py` |
| `CoSolverInductive` | 2 | `SolverInductive` | `CoTypes/CoInductive/Solver/default.py` |
| `CoIndexMetaInductive` | 3 | `IndexMetaInductive` | `CoTypes/CoInductive/IndexMeta/default.py` |
| `CoCatalogEntryInductive` | 2 | `CatalogEntryInductive` | `CoTypes/CoInductive/CatalogEntry/default.py` |

```lean
structure CoFrameInductive where
  columnsPresent : Bool := false   -- all 5 OHLCV columns exist
  dtypesNumeric  : Bool := false   -- all columns are numeric (float64)
  noNulls        : Bool := false   -- no NaN/null values
  indexSorted    : Bool := false   -- datetime index is monotonically sorted
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Inductive/{X}/` has a `CoTypes/CoInductive/{X}/`
- [ ] All fields are `Bool` with default `False`
- [ ] Note: inline enums (10 to be extracted) do NOT need CoInductive duals — they are exhaustive by construction
