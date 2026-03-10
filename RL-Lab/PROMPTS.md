# PROMPTS.md

Lab-specific prompt library for RL-Lab. Extends the root Universes/PROMPTS.md with prompts specialized for the RL quant pipeline.

Read Universes/PROMPTS.md first for universal prompts. This file adds RL-Lab-specific prompts.

---

## 1. Phase-Specific Prompts

### 1.1 Discovery Phase Audit

```
Audit the Discovery phase (Phase 1, BEC) in RL-Lab/:

1. Read Types/Hom/Discovery/default.py — verify fields: io_indices, catalog_source, min_trend_score, min_frame_length, trend_lookback, index_filter (FilterDependent), index_threshold (ThresholdDependent)
2. Read Types/IO/IODiscoveryPhase/default.py — verify:
   - Reads from catalog source (yfinance screener)
   - Routes by IndexClass (stock/crypto/forex)
   - Filters by FilterDependent quantile params
   - Filters by trend score (ADX)
   - Persists DiscoveryProductOutput via StoreMonad
3. Read Types/Product/Discovery/Output/default.py and Meta/default.py
4. Read CoTypes/CoIO/CoIODiscoveryPhase/default.py — verify observer probes StoreMonad
5. Check default.json matches Settings fields
6. Report: PASS/FAIL per check
```

### 1.2 Transform Phase Audit

```
Audit the Transform phase (Phase 3, Liquid Crystal) in RL-Lab/:

1. Read Types/Hom/Transform/default.py — verify fields: basis (BasisInductive), level, threshold_mode, trend_period, envelope_period, envelope_multiplier, regime_threshold
2. Read Types/IO/IOTransformPhase/default.py — verify:
   - Reads ingest blob from StoreMonad
   - Applies basis function (wavelet) denoising via pywt
   - Computes trend indicators (ADX, SuperTrend)
   - Prefixes all feature columns with `feature_`
   - Persists TransformProductOutput via StoreMonad
3. Verify no domain jargon in type names (BasisInductive not WaveletName, etc.)
4. Report: PASS/FAIL per check
```

### 1.3 Solve Phase Audit

```
Audit the Solve phase (Phase 4, Liquid) in RL-Lab/:

1. Read Types/Hom/Solve/default.py — verify fields: solver (SolverInductive), n_parallel, learning_rate, budget, horizon_min, normalize_input, normalize_signal
2. Read Types/IO/IOSolvePhase/default.py — verify:
   - Uses SB3 (stable-baselines3) for RL solving
   - Supports PPO/SAC/DQN/A2C via SolverInductive dispatch
   - Uses SubprocVecEnv/DummyVecEnv + VecNormalize
   - Implements early stopping (reward plateau detection)
   - Saves model + normalize blobs to StoreMonad
3. Verify ExecutionDependent is used for env params (not hardcoded)
4. Report: PASS/FAIL per check
```

### 1.4 Compose Phase Audit

```
Audit the Compose phase (Phase 7, QGP) in RL-Lab/:

1. Read Types/Hom/Compose/default.py — verify fields: stride_min, solve_split_pct, search, search_fiber (SearchDependent)
2. Read Types/IO/IOComposePhase/default.py — verify:
   - Orchestrates: Discovery -> Ingest -> Transform -> (Solve -> Eval)* walk-forward
   - Instantiates sub-phase Hom types locally with defaults (no cross-phase Hom imports)
   - Optional Optuna search via `search=true`
   - Persists ComposeProductOutput as JSON blob
3. Verify no PipelineHom or aggregator types (dissolved in Session 3)
4. Report: PASS/FAIL per check
```

---

## 2. Rename Completion Prompts

### 2.1 Complete Remaining Field/Method Renames

```
Read RL-Lab/DICTIONARY.md (Naming Normalization Table, Field Names section).
The following renames are NOT yet applied in code. Execute them:

**Inductive methods:**
- FrameInductive: `from_dataframe` -> `from_io_frame`, `to_dataframe` -> `to_io_frame`
- CatalogInductive: `from_response` -> `from_io_response`, `get_tickers` -> `indices`
- Update ALL call sites in Types/IO/ executors and CoTypes/CoIO/ observers

**Identity fields:**
- SessionIdentity: `name` -> `label`

**Dependent fields:**
- ExecutionDependent: `positions` -> `position_space`
- FilterDependent: `min_volume_percentile` -> `volume_quantile`, `min_price_percentile` -> `price_quantile`, `max_spread_pct` -> `volatility_bound`, `min_turnover_pct` -> `turnover_quantile`, `require_shortable` -> `require_invertible`, `min_universe_size` -> `min_catalog_size`
- ThresholdDependent: `min_qualifying_tickers` -> `min_qualifying_indices`, `max_api_failures` -> `max_io_failures`
- SearchDependent: `n_trials` -> `budget`, `n_parallel` -> `parallelism`

After renaming, update all `default.json` configs and run `rg` sweep to verify no old names remain.
```

### 2.2 Complete dry-python/returns Integration

```
Read RL-Lab/AGENTS.md (invariant 21, dry-python/returns section).
`returns>=0.23` is already in pyproject.toml. Now wrap all IO executors:

For each of the 7 IO executors in Types/IO/:
1. Add imports: `from returns.result import safe`, `from returns.io import impure_safe, IOResult`
2. Wrap the main `run()` function: return `IOResult[{ProductOutput}, ErrorMonad]`
3. Replace all bare `try`/`except` with `@impure_safe`
4. For pure fallible computations, use `@safe` returning `Result[T, ErrorMonad]`

For StoreMonad (Types/Monad/Store/default.py):
1. Add import: `from returns.maybe import Maybe`
2. Wrap `get()`, `latest()` to return `Maybe[ArtifactMonad]`

For IOComposePhase:
1. Use `flow()` / `pipe()` for sequential phase composition

Run type checker after to verify types propagate.
```

---

## 3. Frozen Phase Chain Reference

For quick substitution into prompts:

```
Phases: Discovery, Ingest, Transform, Solve, Eval, Project, Compose
Matter:  BEC,       Crystal, LiqCrystal, Liquid, Gas,  Plasma,  QGP
Strata:  1,         2,       3,          4,      5,    6,       7

IO Executors:     IODiscoveryPhase, IOIngestPhase, IOTransformPhase, IOSolvePhase, IOEvalPhase, IOProjectPhase, IOComposePhase
CoIO Observers:   CoIODiscoveryPhase, CoIOIngestPhase, CoIOTransformPhase, CoIOSolvePhase, CoIOEvalPhase, CoIOProjectPhase, CoIOComposePhase

Justfile (cata-):  cata-discover, cata-ingest, cata-transform, cata-solve, cata-eval, cata-project
Justfile (hylo-):  hylo-compose
Justfile (ana-):   ana-discover, ana-ingest, ana-transform, ana-solve, ana-eval, ana-project, ana-compose, ana-check
```

---

## 4. Type Name Reference

For quick substitution into prompts:

```
Identity:   IndexIdentity, SessionIdentity
Inductive:  SolverInductive, SeverityInductive, MeasureInductive, FrameInductive, CatalogInductive, CatalogEntryInductive, IndexMetaInductive
Dependent:  ExecutionDependent, ConstraintDependent, FilterDependent, ThresholdDependent, SearchDependent
Hom:        DiscoveryHom, IngestHom, TransformHom, SolveHom, EvalHom, ProjectHom, ComposeHom
Product:    {Phase}ProductOutput, {Phase}ProductMeta (x7 phases)
Monad:      ErrorMonad, MeasureMonad, SignalMonad, EffectMonad, StoreMonad, ArtifactMonad
IO:         IO{Phase}Phase (x7)

CoIdentity:  CoIndexIdentity, CoSessionIdentity
CoInductive: CoSolverInductive, CoFrameInductive, CoCatalogInductive, CoCatalogEntryInductive, CoIndexMetaInductive
CoDependent: CoExecutionDependent, CoConstraintDependent, CoFilterDependent, CoThresholdDependent, CoSearchDependent
CoHom:       Co{Phase}Hom (x7)
CoProduct:   Co{Phase}ProductOutput, Co{Phase}ProductMeta (x7)
Comonad:     TraceComonad, CoErrorComonad, CoMeasureComonad, CoSignalComonad, CoStoreComonad
CoIO:        CoIO{Phase}Phase (x7)
```
