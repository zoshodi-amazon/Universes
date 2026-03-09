# CoStratum 1 — CoIdentity (BEC Dual, Coterminal)

## Lean 4 Template

```lean
-- CoStratum 1: CoIdentity (BEC dual, coterminal)
-- Lean keyword: structure (observation witness, all Bool fields)
-- Duality: Identity ↔ CoIdentity (terminal ↔ coterminal)
-- Where Identity says "what exists?", CoIdentity asks "is it reachable?"

structure Co{Name}Identity where
  {fields : Bool := false}    -- introspection probes, all default false
  deriving Repr, Lean.ToJson, Lean.FromJson

-- Co-closure: every Identity type has exactly one CoIdentity witness.
-- Every Bool field maps to a reachability/validity probe.
```

## Duality & Closure

**Dual of:** Stratum 1 (Identity, terminal objects).

Where `AssetIdentity` declares "this asset exists with these properties," `CoAssetIdentity` asks "is this asset actually reachable? valid? identified?" — the coterminal dual that witnesses whether the Identity's referent is live in the world.

**Pattern:** All fields are `Bool`, defaulting to `False`. The CoIO observer flips them to `True` as it successfully probes each aspect. A fully-`True` CoIdentity witness means the Identity type's referent is fully reachable.

## Implemented Types

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `CoAssetIdentity` | 3 | `AssetIdentity` | `CoTypes/CoIdentity/Asset/default.py` |
| `CoRunIdentity` | 3 | `RunIdentity` | `CoTypes/CoIdentity/Run/default.py` |

```lean
structure CoAssetIdentity where
  tickerValid       : Bool := false   -- IO probe: does the ticker resolve at the data vendor?
  dataReachable     : Bool := false   -- IO probe: can we download bars for this ticker?
  exchangeIdentified: Bool := false   -- IO probe: do we know which exchange this trades on?
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoRunIdentity where
  blobExists   : Bool := false   -- IO probe: is the run's blob directory on disk?
  dbRowExists  : Bool := false   -- IO probe: is there a StoreMonad row for this run?
  storeReachable: Bool := false  -- IO probe: can we connect to the SQLite DB?
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Identity/{X}/` has a `CoTypes/CoIdentity/{X}/`
- [ ] All fields are `Bool` with default `False`
- [ ] Every field maps to a concrete IO probe in the CoIO observer
