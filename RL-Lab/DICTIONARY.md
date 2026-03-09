# DICTIONARY.md — Domain Term Reference

Every domain-specific term in this codebase mapped to its type-theoretic phase,
matter state, directory location, and definition.

**Read this file when encountering an unfamiliar term. Update it when adding new terms.**

---

## Type-Theoretic Phases (Quick Reference)

| # | Phase | Type Theory | Matter | Directory | Suffix |
|---|-------|-------------|--------|-----------|--------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` | `{Domain}Identity` |
| 2 | Inductive | ADT / Sum | Crystalline | `Types/Inductive/` | `{Domain}Inductive` |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` |

CoTypes (dual — 1-1 correspondence, no exceptions):

| # | Phase | Directory | Suffix | Dual of |
|---|-------|-----------|--------|---------|
| 1 | CoIdentity | `CoTypes/CoIdentity/` | `Co{Domain}Identity` | Identity |
| 2 | CoInductive | `CoTypes/CoInductive/` | `Co{Domain}Inductive` | Inductive |
| 3 | CoDependent | `CoTypes/CoDependent/` | `Co{Domain}Dependent` | Dependent |
| 4 | CoHom | `CoTypes/CoHom/` | `{Domain}CoHom` | Hom |
| 5 | CoProduct | `CoTypes/CoProduct/` | `{Domain}CoProduct{Kind}` | Product |
| 6 | Comonad | `CoTypes/Comonad/` | `{Domain}Comonad` | Monad |
| 7 | CoIO | `CoTypes/CoIO/` | `CoIO{Phase}Phase` | IO |

---

## A — Asset and Algorithm Terms

### ADX (Average Directional Index)
- **What:** Technical indicator measuring trend strength on a 0-100 scale. High ADX = strong trend regardless of direction.
- **Where used:** `IODiscoveryPhase` (filtering), `IOFeaturePhase` (feature column), `DiscoveryHom.min_adx`, `FeatureHom.adx_period`
- **Phase:** Hom (as config param), Feature (as computed feature)
- **Type:** `float` bounded `[0.0, 100.0]`

### AlgoIdentity
- **What:** 4-variant enum for RL algorithm selection: PPO, SAC, DQN, A2C.
- **Where:** `Types/Inductive/Algo/default.py`
- **Phase:** Inductive (Crystalline) — it is a finite sum type (ADT), not Identity despite the name.
- **Note:** Name is `AlgoIdentity` for historical reasons but lives in `Inductive/` because a 4-variant enum is a sum type.

### AssetIdentity
- **What:** Terminal object defining a single tradeable asset: ticker symbol, bar interval, trade hours, holiday calendar.
- **Where:** `Types/Identity/Asset/default.py`
- **Phase:** Identity (BEC) — exactly one canonical configuration per asset.
- **Fields:** asset_type, io_ticker, interval_min, trade_start_min, trade_end_min, holidays

### AssetType
- **What:** 3-variant enum: stock, crypto, forex. Determines asset class routing in Discovery.
- **Where:** `Types/Identity/Asset/default.py` (supporting enum)
- **Phase:** Identity (BEC)

### ArtifactRow
- **What:** Single row returned from StoreMonad queries. Represents one stored artifact.
- **Where:** `Types/Monad/Store/default.py`
- **Phase:** Monad (Plasma) — supporting type for StoreMonad.
- **Fields:** run_id, phase, artifact_type, blob_path, metadata_json, created_at

---

## B — Broker Terms

### BrokerMode
- **What:** 3-variant enum: sim (backtest only), paper (Alpaca paper trading), live (Alpaca live trading).
- **Where:** `Types/Dependent/Env/default.py` (supporting enum)
- **Phase:** Dependent (Liquid Crystal)

### broker_mode
- **What:** Field on `EnvDependent` that toggles execution layer. Gym env stays pure across all modes.
- **Phase:** Dependent (Liquid Crystal)

---

## C — Catamorphism, CoTypes, and Category Terms

### Catamorphism (cata-)
- **What:** The unique algebra homomorphism from an initial algebra to any other algebra. Recursion scheme: fold. Consumes structure inward (leaves -> root).
- **Domain:** `cata-*` justfile commands. Production operations that fold typed specifications into artifacts. `cata-train` folds TrainHom into a trained model.
- **Prefix:** `cata-` (justfile)
- **6FF:** f* (pushforward), f! (shriek push)

### Anamorphism (ana-)
- **What:** The unique coalgebra homomorphism from any coalgebra to a terminal coalgebra. Recursion scheme: unfold. Generates structure outward (seed -> leaves).
- **Domain:** `ana-*` justfile commands. Observation operations that unfold artifact state into typed evidence. `ana-eval` unfolds the last EvalProductOutput from the store.
- **Prefix:** `ana-` (justfile)
- **6FF:** f* (pullback), f! (shriek pullback), Hom (internal)

### Hylomorphism (hylo-)
- **What:** Composition of an anamorphism followed by a catamorphism: `cata . ana`. Unfold then fold. No intermediate data structure is materialized.
- **Domain:** `hylo-*` justfile commands. Composite operations: observe then produce. `hylo-main` = validate then run full pipeline.
- **Prefix:** `hylo-` (justfile)
- **6FF:** tensor (x)

### CoIdentity
- **What:** Coalgebraic dual of Identity. Coterminal introspection witnesses — probes that answer: is this terminal object present? reachable? valid?
- **Where:** `CoTypes/CoIdentity/`
- **Instances:** `CoAssetIdentity` (Asset/), `CoRunIdentity` (Run/)
- **Dual of:** `Types/Identity/`

### CoInductive
- **What:** Coalgebraic dual of Inductive. Elimination forms — parsers, validators, exhaustiveness witnesses for each ADT. Given a value, is it a valid constructor?
- **Where:** `CoTypes/CoInductive/`
- **Instances:** `CoOHLCVInductive` (OHLCV/), `CoScreenerInductive` (Screener/), `CoAlgoIdentity` (Algo/), `CoTickerInfoInductive` (TickerInfo/), `CoScreenerQuoteInductive` (ScreenerQuote/)
- **Dual of:** `Types/Inductive/`

### CoDependent
- **What:** Coalgebraic dual of Dependent. Lifting property / cofibration — schema conformance validators. Given a serialized blob and an index, does the observation inhabit the expected fiber?
- **Where:** `CoTypes/CoDependent/`
- **Instances:** `CoEnvDependent` (Env/), `CoRiskDependent` (Risk/), `CoLiquidityDependent` (Liquidity/), `CoAlarmDependent` (Alarm/), `CoOptimizeDependent` (Optimize/)
- **Dual of:** `Types/Dependent/`

### CoHom
- **What:** Coalgebraic dual of Hom. Observer input configurations — observation specifications that define what to check per phase.
- **Where:** `CoTypes/CoHom/`
- **Instances (observer):** TailCoHom, VisualizeCoHom
- **Instances (per-phase):** CoDiscoveryHom, CoIngestHom, CoFeatureHom, CoTrainHom, CoEvalHom, CoServeHom, CoMainHom

### CoPhaseId
- **What:** 2-variant enum identifying observer executors: tail, visualize. Distinct from PhaseId.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad

### CoProduct
- **What:** Coalgebraic dual of Product. Observer outputs + meta — what an observer saw.
- **Where:** `CoTypes/CoProduct/`
- **Instances:** TailCoProductOutput, TailCoProductMeta, VisualizeCoProductOutput, VisualizeCoProductMeta

### Comonad
- **What:** Coalgebraic dual of Monad. Observation cursor state — where in the stream the observer is. `extract` gives the current observation. `extend` maps over observation history.
- **Where:** `CoTypes/Comonad/`
- **Instance:** TraceComonad

### CoIO
- **What:** Coalgebraic dual of IO. Observer executors — probes that read from the external world without modifying it.
- **Where:** `CoTypes/CoIO/`
- **Instances (observer):** IOTailPhase (B14: should be CoIOTailPhase), IOVisualizePhase (B15: should be CoIOVisualizePhase)
- **Instances (per-phase):** CoIODiscoveryPhase, CoIOIngestPhase, CoIOFeaturePhase, CoIOTrainPhase, CoIOEvalPhase, CoIOServePhase, CoIOMainPhase
- **Instance (meta):** CoIOValidatePhase

---

## D — Data and Dependent Terms

### db4 (Daubechies-4)
- **What:** Wavelet family used for signal denoising. Default choice for smooth denoising of financial time series.
- **Where:** `FeatureHom.wavelet` default value
- **Phase:** Hom (Liquid)

### default.json
- **What:** Committed JSON config file for each IO executor. The IO boundary — equivalent to a lock file.
- **Where:** Every `Types/IO/IO{X}Phase/` and `CoTypes/CoIO/CoIO{X}Phase/` directory.
- **Invariant:** Must be faithful serialization of the Settings type. Regenerate via `just ana-validate`.

---

## E — Environment and Eval Terms

### EnvDependent
- **What:** Parameterized trading environment configuration shared across Train, Eval, and Serve.
- **Where:** `Types/Dependent/Env/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** initial_value, fees_pct, borrow_rate_pct, positions, broker_mode, io_broker_key

### EvalHom
- **What:** Eval phase input — configures the evaluation window length.
- **Where:** `Types/Hom/Eval/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** forward_steps_min

### EvalProductOutput / EvalProductMeta
- **What:** Eval phase output — portfolio return, final value, threshold status, risk gate triggers.
- **Where:** `Types/Product/Eval/Output/default.py`, `Types/Product/Eval/Meta/default.py`
- **Phase:** Product (Gas)

---

## F — Feature Terms

### feature_ prefix
- **What:** All engineered feature columns are prefixed `feature_`. Enforced by regex `^feature_[a-z_]+$`.
- **Where:** `FeatureProductOutput.feature_names` constraint
- **Phase:** Product (Gas)

### FeatureHom
- **What:** Feature phase input — wavelet params, indicator params, regime threshold.
- **Where:** `Types/Hom/Feature/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** wavelet, level, threshold_mode, adx_period, supertrend_period, supertrend_multiplier, regime_threshold

---

## G — Gym Terms

### gym-trading-env
- **What:** Third-party Gymnasium-compatible trading environment. Provides the observation space, action space, and default log-return reward.
- **Where:** Used in IOTrainPhase, IOEvalPhase, IOServePhase.
- **Invariant:** Default reward is never overridden. Stop-loss/take-profit are external checks, not reward shaping.

---

## H — Hom Terms

### Hom
- **What:** Phase input type. Morphisms flowing INTO a phase. Named after Hom-sets in category theory.
- **Where:** `Types/Hom/`
- **Instances:** DiscoveryHom, IngestHom, FeatureHom, TrainHom, EvalHom, ServeHom, MainHom, PipelineHom, ServeInputHom
- **Phase:** Liquid (state 4)

### HolidayCalendar
- **What:** 3-variant enum: none, us_market, bank. Determines which days to skip.
- **Where:** `Types/Identity/Asset/default.py` (supporting enum)
- **Phase:** Identity (BEC)

---

## I — Identity and Inductive Terms

### Identity (type phase)
- **What:** Terminal objects with exactly one canonical inhabitant. Shared fixed points.
- **Where:** `Types/Identity/`
- **Instances:** AssetIdentity, RunIdentity
- **Matter:** BEC (Bose-Einstein Condensate) — coldest, most fundamental.

### Inductive (type phase)
- **What:** Sum types / ADTs. Structural validation schemas, finite enums, external data wrappers.
- **Where:** `Types/Inductive/`
- **Instances:** OHLCVInductive, ScreenerInductive, ScreenerQuoteInductive, TickerInfoInductive, AlgoIdentity
- **Matter:** Crystalline — rigid structure, validates shape.

### io_ prefix
- **What:** Convention for fields that cross the IO boundary (external inputs/outputs). e.g., `io_ticker`, `io_universe`, `io_broker_key`.
- **Rule:** Fields prefixed `io_` are external-facing. They come from outside the system.

---

## L — Liquidity Terms

### LiquidityDependent
- **What:** Relative (percentile-based) liquidity filters for asset-agnostic discovery.
- **Where:** `Types/Dependent/Liquidity/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** min_volume_percentile, min_price_percentile, max_spread_pct, min_turnover_pct, require_shortable, enabled, min_universe_size

---

## M — Monad and Main Terms

### MainHom
- **What:** Main phase input — walk-forward windowing + Optuna config.
- **Where:** `Types/Hom/Main/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** stride_min, train_split_pct, optimize, optimize_config

### MetricMonad
- **What:** Single metric observation point — name, value, kind (counter or gauge).
- **Where:** `Types/Monad/Metric/default.py`
- **Phase:** Monad (Plasma)

### Monad (type phase)
- **What:** Effect record types. What happened during execution — errors, metrics, alarms, store operations.
- **Where:** `Types/Monad/`
- **Instances:** ErrorMonad, MetricMonad, AlarmMonad, ObservabilityMonad, StoreMonad
- **Matter:** Plasma — hot, effectful.

---

## O — Observability and OHLCV Terms

### ObservabilityMonad
- **What:** Free observability structure composed into every ProductMeta. Collects errors, metrics, alarms, timing.
- **Where:** `Types/Monad/Observability/default.py`
- **Phase:** Monad (Plasma)
- **Fields:** errors, metrics, alarms, phase, duration_s, started_at, completed_at

### OHLCV
- **What:** Open, High, Low, Close, Volume — standard financial price bar format.
- **Where:** `Types/Inductive/OHLCV/default.py`
- **Phase:** Inductive (Crystalline) — structural validation of external DataFrame data.

### OptimizeDependent
- **What:** Optuna hyperparameter search configuration — trial count, parallelism, search space bounds.
- **Where:** `Types/Dependent/Optimize/default.py`
- **Phase:** Dependent (Liquid Crystal)

---

## P — Product and Phase Terms

### PhaseId
- **What:** 8-variant enum identifying pipeline phases: discovery, ingest, feature, train, eval, serve, pipeline, optimize.
- **Where:** `Types/Monad/Error/default.py`
- **Phase:** Monad (Plasma) — supporting enum for ErrorMonad.

### PipelineHom
- **What:** Composite Hom type bundling per-phase inputs for IOMainPhase walk-forward orchestration.
- **Where:** `Types/Hom/Pipeline/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** discovery (DiscoveryHom), ingest (IngestHom), feature (FeatureHom), train (TrainHom), eval (EvalHom)
- **Note:** Extracted to keep IOMainPhase Settings at <=7 fields. IOMainPhase destructures it during walk-forward execution. Parallel to ServeInputHom.

### Product (type phase)
- **What:** Phase outputs + meta. Computed results expanding outward from a phase.
- **Where:** `Types/Product/`
- **Structure:** `{Phase}/Output/default.py` + `{Phase}/Meta/default.py` for each of 7 phases.
- **Matter:** Gas — expanding, observable.

---

## R — Run and Risk Terms

### RiskDependent
- **What:** Per-step risk gate parameters — stop-loss and take-profit thresholds.
- **Where:** `Types/Dependent/Risk/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** stop_loss_pct (negative, e.g. -2.0), profit_threshold_pct (positive, e.g. 0.5)

### RunIdentity
- **What:** Terminal object defining a single pipeline run: ID, timestamp, seed, name, store, verbosity.
- **Where:** `Types/Identity/Run/default.py`
- **Phase:** Identity (BEC)
- **Fields:** run_id (8-char hex), run_ts (YYYYMMDD-HHMM), seed, name, store, verbose

### run_id
- **What:** 8-character hex string uniquely identifying a pipeline run. Auto-generated from UUID prefix.
- **Pattern:** `^[a-f0-9]{8}$`
- **Scope:** Keys all artifact storage, blob paths, and audit logs.

---

## S — Store, Serve, and SuperTrend Terms

### ServeHom
- **What:** Serve phase input — which model to serve, polling cadence, session limits, staleness gate.
- **Where:** `Types/Hom/Serve/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** train_run_id, io_algo, poll_interval_s, max_bars, max_model_age_min

### ServeInputHom
- **What:** Composite Hom type bundling sub-phase inputs for IOServePhase live serving loop.
- **Where:** `Types/Hom/ServeInput/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** feature (FeatureHom), ingest (IngestHom)
- **Note:** Extracted to keep IOServePhase Settings at <=7 fields. Parallel to PipelineHom.

### StoreMonad
- **What:** Typed artifact store binding SQLite metadata to filesystem blobs. The IO boundary.
- **Where:** `Types/Monad/Store/default.py`
- **Phase:** Monad (Plasma)
- **Fields:** db_url, blob_dir, run_id, phase, docs_dir
- **Operations:** put(), get(), latest(), all_runs(), blob_path_for()

### SuperTrend
- **What:** Trend-following indicator based on ATR (Average True Range). Outputs direction: +1 (uptrend) or -1 (downtrend).
- **Where:** `FeatureHom.supertrend_period`, `FeatureHom.supertrend_multiplier`
- **Feature column:** `feature_supertrend_dir` clipped to [-1, 1]

---

## T — Train and Trace Terms

### TraceComonad
- **What:** Coalgebraic observation cursor — tracks where an observer is in the event/artifact stream.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad (dual of Monad)
- **Fields:** observer_id, cursor, events_seen, connection_ok, last_seen_at

### TrainHom
- **What:** Train phase input — algorithm, parallelism, learning rate, timesteps, normalization flags.
- **Where:** `Types/Hom/Train/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** algo, n_envs, learning_rate, total_timesteps, episode_duration_min, normalize_obs, normalize_reward

---

## V — VecNormalize Terms

### VecNormalize
- **What:** SB3 wrapper that normalizes observations and rewards using running statistics. The only enhancement layer between raw gym env and the RL agent.
- **Where:** IOTrainPhase (wraps env), IOEvalPhase (loads saved stats), IOServePhase (loads saved stats).
- **Invariant:** This is the single normalization layer. No other obs/reward transformations are applied.

---

## W — Wavelet Terms

### Wavelet denoising
- **What:** Signal processing technique using discrete wavelet transform (DWT) to separate signal from noise. Applied to all 5 OHLCV channels.
- **Algorithm:** Decompose -> threshold detail coefficients (soft/hard) -> reconstruct.
- **Output per channel:** 3 features (denoised_pct, approx_pct, detail_energy) = 15 features total.
- **Config:** `FeatureHom.wavelet` (family), `.level` (depth), `.threshold_mode` (soft/hard).

### WaveletName
- **What:** 5-variant enum: db4, db6, db8, sym4, sym6. Wavelet family selection.
- **Where:** `Types/Hom/Feature/default.py` (supporting enum)
- **Phase:** Hom (Liquid)

---

## 6 — 6-Functor Formalism and Formal Terms

### 6-Functor Formalism
- **What:** Grothendieck's six operations on sheaves: f* -| f* (pullback/pushforward), f! -| f! (shriek), x -| Hom (tensor/internal hom). Three adjoint pairs classifying all morphisms.
- **Domain:** Every justfile recipe is classified by one of the six functors. `ana-*` uses f* (pullback), f! (shriek pullback), Hom (internal). `cata-*` uses f* (pushforward), f! (shriek push). `hylo-*` uses x (tensor product).

### Bidirectional Path Closure
- **What:** Agreement between two observation paths to the same codomain. Path (a) destructures the typed output (schema observation). Path (b) probes the live artifact (runtime observation). Both yield CoProduct. If they agree, the path is closed.
- **Domain:** CoTypes/ is the bidirectional path closure witness. Path (a): `Hom -> toJson -> fromJson -> Hom` roundtrip (validated by `ana-validate`). Path (b): `Product -> CoIO observer -> CoProduct` (validated by per-phase `ana-{phase}` commands). Agreement = correctness.

### Free-Forgetful Adjunction (F -| U)
- **What:** The relationship between production and observation. F (free, left adjoint) is the production path: Types/ -> IO -> Product. U (forgetful, right adjoint) is the observation path: Product -> CoIO -> CoProduct. The unit n = toJson, the counit e = fromJson. Roundtrip closure (fromJson . toJson = id) is the adjunction identity.
- **Domain:** The system is well-typed when what you build (F) is what you observe (U), modulo the forgotten construction path.

### Profunctor
- **What:** A bifunctor P : C^op x D -> Set, contravariant in the first argument (inputs), covariant in the second (outputs).
- **Domain:** Every phase is a profunctor. Hom/ is the contravariant leg (domain), Product/ is the covariant leg (codomain), and the IO executor is the effectful arrow between them. Pattern: `Hom(phase) --IO executor--> Product(phase)`.
