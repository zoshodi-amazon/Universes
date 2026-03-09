# CoStratum 7 — CoIO (QGP Dual, Observers)

## Lean 4 Template

```lean
-- CoStratum 7: CoIO (QGP dual, observers)
-- Lean keyword: IO (built-in monad, same as Stratum 7)
-- Duality: IO (executors) ↔ CoIO (observers)
-- Where IO executors produce artifacts (effectful, constructive),
--   CoIO observers probe artifacts (effectful, observational).
-- The observer is a covariant presheaf: it reads without modifying.

structure CoIO{Phase}Phase.Settings where
  {phase}  : Co{Phase}Hom := {}     -- what to check (CoStratum 4)
  store    : StoreMonad   := {}     -- where to probe (Stratum 6)
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- The observer morphism type: Settings → IO CoProductOutput. -/
def CoIO{Phase}Phase.run : Settings → IO Co{Phase}ProductOutput
```

## Duality & Closure

**Dual of:** Stratum 7 (IO, executors).

Where `IODiscoveryPhase.run` produces a `DiscoveryProductOutput` (the constructive direction), `CoIODiscoveryPhase.run` observes the produced artifact and yields `CoDiscoveryProductOutput` (the observational direction). The IO executor IS the algebra's morphism. The CoIO observer IS the coalgebra's comorphism.

**Observation profunctor per phase:**
```
CoHom(phase) ──CoIO observer──▶ CoProduct(phase)
  (what to check)   (probe)       (what was seen)
```

**Production ⊣ Observation adjunction:**
- Production (Types/ → IO → Product) is the **free** direction
- Observation (Product → CoIO → CoProduct) is the **forgetful** direction
- Agreement between them is the **bidirectional path closure**

## Implemented Observers (7 = one per phase)

| Observer | Probes | File |
|----------|--------|------|
| `CoIODiscoveryPhase` | StoreMonad for latest discovery artifact | `CoTypes/CoIO/CoIODiscoveryPhase/default.py` |
| `CoIOIngestPhase` | Ingest artifact + blob readability | `CoTypes/CoIO/CoIOIngestPhase/default.py` |
| `CoIOFeaturePhase` | Feature columns + prefix + count | `CoTypes/CoIO/CoIOFeaturePhase/default.py` |
| `CoIOTrainPhase` | Model blob + normalize blob + reward | `CoTypes/CoIO/CoIOTrainPhase/default.py` |
| `CoIOEvalPhase` | Eval return + render logs + Flask renderer | `CoTypes/CoIO/CoIOEvalPhase/default.py` |
| `CoIOServePhase` | Audit log + orders + shutdown reason | `CoTypes/CoIO/CoIOServePhase/default.py` |
| `CoIOMainPhase` | Pipeline artifact + type validation + Rerun viz | `CoTypes/CoIO/CoIOMainPhase/default.py` |

### CoIOMainPhase — Composite Observer

`CoIOMainPhase` is the composite observer that subsumes validation, visualization, and per-phase observation:

1. **Pipeline artifact probe** — queries StoreMonad for latest main artifact
2. **Type system structural validation** — imports all 67 type modules + 14 IO modules, checks field counts, checks JSON fidelity
3. **Cross-phase Rerun visualization** — logs all artifact metrics to Rerun for visual inspection

Controlled by `CoMainHom` flags: `validate_imports`, `validate_fields`, `validate_json`, `visualize`, `pipeline_completed`.

### Command Surface (7 ana- commands)

| Command | Observer | What It Probes |
|---------|----------|---------------|
| `ana-discover` | `CoIODiscoveryPhase` | universe_resolved, screener_responded, qualifying_found |
| `ana-ingest` | `CoIOIngestPhase` | data_present, schema_valid, bars_sufficient, blob_readable |
| `ana-feature` | `CoIOFeaturePhase` | features_present, column_count_valid, prefix_enforced |
| `ana-train` | `CoIOTrainPhase` | model_present, normalize_present, reward_finite |
| `ana-eval` | `CoIOEvalPhase` | eval_completed, return_recorded, render_logs_present |
| `ana-serve` | `CoIOServePhase` | audit_present, orders_logged, shutdown_clean |
| `ana-main` | `CoIOMainPhase` | artifact probe + type validation + Rerun viz |

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/IO/IO{Phase}Phase/` has a `CoTypes/CoIO/CoIO{Phase}Phase/`
- [ ] Every observer reads `CoHom` spec and writes `CoProduct` result
- [ ] Every observer has a `default.json` and `__main__` block
- [ ] Every `cata-{phase}` has a corresponding `ana-{phase}` (testing IS coalgebraic observation)
- [ ] `CoIOMainPhase` validates structural invariants (field counts, JSON fidelity, import health)
