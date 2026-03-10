# CoStratum 5 — CoProduct (Gas Dual, Coproduct)

## Lean 4 Template

```lean
-- CoStratum 5: CoProduct (Gas dual, coproduct)
-- Lean keyword: structure (observation result: mixed Bool + typed fields)
-- Duality: Product (A × B) ↔ CoProduct (A + B)
-- Where Product records what was produced, CoProduct records what was observed.
-- Split into Output (observation values) and Meta (observation trace).

structure Co{Phase}ProductOutput where
  observerId : String := ""       -- who observed
  {observation Bool + typed fields}
  meta : Co{Phase}ProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure Co{Phase}ProductMeta where
  artifactFound  : Bool := false
  schemaValid    : Bool := false
  {additional meta fields}
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Duality & Closure

**Dual of:** Stratum 5 (Product, phase outputs).

Where `DiscoveryProductOutput` records what the Discovery phase produced (qualifying symbols, universe size), `CoDiscoveryProductOutput` records what the observer **actually saw** when it probed the artifact. This is the coproduct dual — the observation projection.

**Pattern:** Mix of `Bool` fields (pass/fail checks) and typed fields (observed values). CoProduct Output mirrors the structure of Product Output but with observation semantics. CoProduct Meta tracks artifact presence and schema validity.

## Implemented Types (14 = 7 Output + 7 Meta)

| Phase | CoOutput | CoOutput Fields | CoMeta | CoMeta Fields |
|-------|----------|:--------------:|--------|:------------:|
| Discovery | `CoDiscoveryProductOutput` | 5 | `CoDiscoveryProductMeta` | 3 |
| Ingest | `CoIngestProductOutput` | 5 | `CoIngestProductMeta` | 3 |
| Transform | `CoTransformProductOutput` | 5 | `CoTransformProductMeta` | 3 |
| Solve | `CoSolveProductOutput` | 5 | `CoSolveProductMeta` | 3 |
| Eval | `CoEvalProductOutput` | 5 | `CoEvalProductMeta` | 3 |
| Project | `CoProjectProductOutput` | 5 | `CoProjectProductMeta` | 3 |
| Compose | `CoComposeProductOutput` | 7 | `CoComposeProductMeta` | 7 |

```lean
structure CoDiscoveryProductOutput where
  observerId        : String := ""
  universeResolved  : Bool   := false
  catalogResponded  : Bool   := false
  qualifyingFound   : Bool   := false
  meta              : CoDiscoveryProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoDiscoveryProductMeta where
  artifactFound : Bool := false    -- StoreMonad has a discovery artifact row
  schemaValid   : Bool := false    -- metadata_json parses without error
  blobReadable  : Bool := false    -- blob file on disk and readable
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Bidirectional Path Closure

CoProduct is where the two observation paths converge:

- **Path (a):** `Hom → toJson → fromJson → Hom` (schema roundtrip)
- **Path (b):** `Product → CoIO observer → CoProduct` (runtime observation)

Agreement between paths (a) and (b) at the CoProduct level is the **bidirectional path closure** — the proof that the IO executor did what the types said it would.

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Product/{Phase}/` has a `CoTypes/CoProduct/{Phase}/`
- [ ] Each CoProduct has `Output/` and `Meta/` subdirectories
- [ ] Every CoMeta includes `artifact_found`, `schema_valid` fields
- [ ] CoProduct fields correspond to observable aspects of the Product
