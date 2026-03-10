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

Where `IndexIdentity` declares "this index exists with these properties," `CoIndexIdentity` asks "is this index actually reachable? valid? identified?" — the coterminal dual that witnesses whether the Identity's referent is live in the world.

**Pattern:** All fields are `Bool`, defaulting to `False`. The CoIO observer flips them to `True` as it successfully probes each aspect. A fully-`True` CoIdentity witness means the Identity type's referent is fully reachable.

## Implemented Types

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `CoIndexIdentity` | 3 | `IndexIdentity` | `CoTypes/CoIdentity/Index/default.py` |
| `CoSessionIdentity` | 3 | `SessionIdentity` | `CoTypes/CoIdentity/Session/default.py` |

```lean
structure CoIndexIdentity where
  symbolValid       : Bool := false   -- IO probe: does the symbol resolve at the data vendor?
  dataReachable     : Bool := false   -- IO probe: can we download bars for this symbol?
  exchangeIdentified: Bool := false   -- IO probe: do we know which exchange this trades on?
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoSessionIdentity where
  blobExists   : Bool := false   -- IO probe: is the session's blob directory on disk?
  dbRowExists  : Bool := false   -- IO probe: is there a StoreMonad row for this session?
  storeReachable: Bool := false  -- IO probe: can we connect to the SQLite DB?
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Identity/{X}/` has a `CoTypes/CoIdentity/{X}/`
- [ ] All fields are `Bool` with default `False`
- [ ] Every field maps to a concrete IO probe in the CoIO observer
