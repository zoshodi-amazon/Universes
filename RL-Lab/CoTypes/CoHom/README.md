# CoStratum 4 — CoHom (Liquid Dual, Destructors)

## Lean 4 Template

```lean
-- CoStratum 4: CoHom (Liquid dual, destructors)
-- Lean keyword: structure (observation specification, Bool fields defaulting True)
-- Duality: Hom (constructors/morphism domain) ↔ CoHom (destructors/observation spec)
-- Where Hom specifies what to provide (inputs), CoHom specifies what to check (outputs).

structure Co{Phase}Hom where
  {fields : Bool := true}    -- observation flags: what to verify (default: check everything)
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Duality & Closure

**Dual of:** Stratum 4 (Hom, morphism domains).

Where `DiscoveryHom` says "provide these inputs to the Discovery phase," `CoDiscoveryHom` says "check these outputs of the Discovery phase." The CoHom is the **destructor** — it specifies which aspects of the phase's behavior to observe. Default is `True` (check everything).

**Pattern:** All fields are `Bool`, defaulting to `True`. The CoIO observer reads the CoHom spec and only performs the probes that are enabled. Setting a field to `False` skips that observation.

## Implemented Types (7 = one per phase)

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `CoDiscoveryHom` | 4 | `DiscoveryHom` | `CoTypes/CoHom/Discovery/default.py` |
| `CoIngestHom` | 3 | `IngestHom` | `CoTypes/CoHom/Ingest/default.py` |
| `CoTransformHom` | 4 | `TransformHom` | `CoTypes/CoHom/Transform/default.py` |
| `CoSolveHom` | 4 | `SolveHom` | `CoTypes/CoHom/Solve/default.py` |
| `CoEvalHom` | 5 | `EvalHom` | `CoTypes/CoHom/Eval/default.py` |
| `CoProjectHom` | 5 | `ProjectHom` | `CoTypes/CoHom/Project/default.py` |
| `CoComposeHom` | 7 | `ComposeHom` | `CoTypes/CoHom/Compose/default.py` |

```lean
structure CoDiscoveryHom where
  universeResolved   : Bool := true   -- check: did the catalog return symbols?
  catalogResponded   : Bool := true   -- check: did the API respond?
  adxFilterApplied   : Bool := true   -- check: was ADX filtering performed?
  qualifyingFound    : Bool := true   -- check: did any symbols pass all filters?
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Hom/{Phase}/` has a `CoTypes/CoHom/{Phase}/`
- [ ] All fields are `Bool` with default `True`
- [ ] Each field maps to a concrete observation probe in the CoIO observer
