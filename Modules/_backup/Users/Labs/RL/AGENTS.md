# AGENTS.md -- Design Invariants

Rules for any agent (human or AI) working on this codebase.
**Read this file and README.md before every update.**

## Core Project Goal

Autonomous self-hosted quant RL lab:
- Asset-agnostic: stocks, crypto, forex via AssetUnit index type
- Hot-swappable discovery via yfinance screener + ADX regime filtering (highest-ADX ticker chosen)
- Smooth input geometry via wavelet (db4) on OHLCV + trend proxy (ADX/SuperTrend)
- SB3 VecNormalize for obs/reward (only enhancement layer)
- gym-trading-env default reward untouched, per-step stop-loss/take-profit in eval/serve
- Walk-forward batch backtest via IOPipelinePhase
- Train/eval/serve env symmetry: same EnvUnit, broker_mode toggles sim/paper/live

## Process Invariants

- **Docs first.** Update AGENTS.md and README.md before any code change.
- **Read before write.** Re-read both docs before every update.
- **justfile is the only interface.** All phase execution goes through `just {phase}`. No raw `python -m` commands. CLI overrides via pydantic-settings: `just pipeline --train.total_timesteps 10000`. The justfile is the single source of truth for how phases are invoked.

## Frozen Phase Chain

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve
```

## 1:1 Phase Mapping

Every phase has exactly: Input + Output + Monad + justfile entry. No exceptions.

| Phase | Input | Output | Monad | justfile |
|-------|-------|--------|-------|----------|
| Discovery | DiscoveryInput | DiscoveryOutput | IODiscoveryPhase | `discover` |
| Ingest | IngestInput | IngestOutput | IOIngestPhase | `ingest` |
| Feature | FeatureInput | FeatureOutput | IOFeaturePhase | `feature` |
| Train | TrainInput | TrainOutput | IOTrainPhase | `train` |
| Eval | EvalInput | EvalOutput | IOEvalPhase | `eval` |
| Serve | ServeInput | ServeOutput | IOServePhase | `serve` |
| Pipeline | PipelineInput | PipelineOutput | IOPipelinePhase | `pipeline` |
| Optimize | OptimizeInput | OptimizeOutput | IOOptimizePhase | `optimize` |

## Monads (1:1 with justfile)

Every monad is a self-contained IO phase with its own BaseSettings + default.json.

- **IODiscoveryPhase** -- standalone: screener + ADX filter
- **IOIngestPhase** -- standalone: download + cache OHLCV
- **IOFeaturePhase** -- standalone: wavelet denoise + trend indicators (runs ingest first)
- **IOTrainPhase** -- standalone: RL training (runs ingest → feature first)
- **IOEvalPhase** -- standalone: out-of-sample evaluation (runs ingest → feature → train first)
- **IOServePhase** -- standalone: live bar-by-bar serving with broker execution
- **IOPipelinePhase** -- compound: Discovery -> Ingest -> Feature -> (Train -> Eval)*
- **IOOptimizePhase** -- compound: Optuna trials over IOPipelinePhase

## Per-Phase Settings

- Each `Monads/IO{X}Phase/` has its own `default.py` (BaseSettings + logic + `__main__`) and `default.json`
- Each phase is self-contained: reads its own JSON, accepts CLI overrides, no cross-phase imports for settings
- UnitTypes are the only shared types across phases
- No monolithic Config. No PhaseConfig wrapper.

## Matter-Phase Type System

Types follow the free ⊣ forgetful adjunction, mapped to phases of matter:

| Phase | Layer | Description |
|-------|-------|-------------|
| **Solid** | UnitTypes | Irreducible basis vectors, maximally constrained, shared across ≥2 phases |
| **Liquid** | PhaseInputTypes | Bounded configs that flow into phases, structured but reshapable |
| **Gas** | PhaseOutputTypes | Computed artifacts, phase results expanding outward |
| **Plasma** | Monads/Settings | Free composition layer, IO boundary where types get composed from JSON/CLI |

## Architectural Pattern

- **Types/UnitTypes/** -- [Solid] irreducible representations, basis vectors shared across >=2 phases (plain BaseModel)
- **Types/PhaseInputTypes/** -- [Liquid] phase input types (plain BaseModel)
- **Types/PhaseOutputTypes/** -- [Gas] phase output types (plain BaseModel)
- **Monads/** -- [Plasma] IO phase type constructors, each with own BaseSettings + default.json

## Naming Invariants

- `{X}Unit` -- irreducible shared type (basis vector) [Solid]
- `{X}Input` -- phase input type [Liquid]
- `{X}Output` -- phase output type [Gas]
- `IO{X}Phase` -- monad dir in Monads/ [Plasma]
- Every phase has exactly: Input type + Output type + Monad + justfile entry

## Frozen UnitTypes

| Unit | Fields (<=7) |
|------|--------------|
| AssetUnit | asset_type, io_ticker, interval_min, trade_start_min, trade_end_min, holidays |
| RunUnit | run_id, run_ts, seed, name, output_dir, status, verbose |
| EnvUnit | initial_value, fees_pct, borrow_rate_pct, positions, broker_mode, io_broker_key, stop_loss_pct |
| ErrorUnit | phase, message, window_index, severity |
| FieldUnit | RunId, Ticker, FilePath, DirPath, ISODate |

## Frozen PhaseOutputTypes

| Phase | Fields (<=7) |
|-------|--------------|
| DiscoveryOutput | run_id, universe_size, qualifying_tickers, min_adx_used, io_scan_date, n_qualifying, io_data_path |
| IngestOutput | run_id, io_ticker, interval_min, n_bars, io_start_date, io_end_date, io_data_path |
| FeatureOutput | run_id, n_static_features, n_dynamic_features, feature_names, n_valid_bars, io_data_path |
| TrainOutput | run_id, io_model_path, algo, total_timesteps, learning_rate, final_reward, io_normalize_path |
| EvalOutput | run_id, io_ticker, window_index, portfolio_return_pct, final_value*, threshold_met*, position |
| ServeOutput | run_id, io_ticker, n_bars_served, portfolio_return_pct, position_taken, n_trades, status |
| PipelineOutput | run_id, n_windows, win_rate_pct*, duration_s, status, results, errors |
| OptimizeOutput | run_id, n_completed, io_model_path, best_lr, best_timesteps, best_win_rate_pct, io_study_path |

*Derivable fields kept for convenience. Flagged for future refactor.

## Env Parallelism

- TrainInput.n_envs controls parallel env count (1-16)
- n_envs > 1 uses SubprocVecEnv (sim mode only)
- n_envs == 1 or paper/live mode uses DummyVecEnv
- Eval/Serve always use DummyVecEnv (single stream)
- MlpPolicy is hardcoded (always correct for flat observations)

## Discovery Flow

- `io_universe: []` (default) triggers yfinance screener fetch via `yf.screen(screener)`
- `io_universe: ["AAPL", "TSLA"]` (CLI override) skips screener, uses provided list directly
- `screener` field on DiscoveryInput maps to yfinance predefined queries (e.g. `most_actives`)
- IODiscoveryPhase filters universe by ADX >= min_adx, sorts qualifying tickers by ADX descending
- Compound phases take `qualifying_tickers[0]` (highest ADX) as the chosen asset for the run
- Chosen ticker overrides `asset.io_ticker` for Ingest -> Feature -> Train -> Eval/Serve

## Type Invariants

- <=7 params per typed object; >7 signals split
- Every field has `Field(description=...)`. Types are documentation.
- **Output fields must be orthogonal.** No field derivable from other fields on the same Output. Derived metrics are folds over results lists, not stored fields.
- Every field bounded. No unbounded types. No Optional/None. No placeholders. No NaN.
- IDs are generated UUIDs. Asset-agnostic via AssetUnit.
- UnitTypes are immutable across a phase chain. A model trained with a given AssetUnit cannot be served with a different AssetUnit. All phases in a chain must agree on the same basis vectors. Mismatched UnitTypes is a type error at the IO boundary.
- No misnomers. Semantic precision is the highest-priority invariant. A misnomer is the highest degree of violation.
- No shared helper functions between Monads. If two Monads need identical logic, the types enforce the contract. Shared code signals a coupling violation and a potential phase split.
- Eval/Serve env parity. Both construct gym envs from the same UnitTypes. Types are the parity contract, not shared implementation.
- Env/ is a typed IO boundary. `Env/Inputs/` contains ephemeral runtime reads (cache, credentials, external data) — the free pairing. `Env/Outputs/` contains persisted phase artifacts (models, features, logs, render logs, docs) — the forgetful pairing. Pydantic Input/Output types define the I/O schemas. No untyped data crosses the boundary.
- No dropna. No emojis. No print in Monads. No ad-hoc overrides.
- No magic numbers in Monads: all values from phase settings through Input types/UnitTypes.
- No inline comments in Monads. Documentation lives in types and module docstrings.
- Every Monad run() wraps IO in try/except, returns typed ErrorUnit on failure. Exceptions are typed fixpoints.
- Every env lifecycle wrapped in try/finally for cleanup.
- Every episode starts flat (position=0.0) and closes flat before returning. No position state leaks between episodes. Context is persisted to Outputs, not carried in memory.
- Optimization search spaces must be strictly contained within existing type bounds. Optuna never searches over design fixpoints (interval, positions, episode duration, feature geometry, fees, stop-loss).
- No unvalidated io_ path loads. Check file exists before read.
- No empty DataFrame propagation. Validate len(df) > 0 at phase entry.
- `io_` prefix for external required inputs, `ValidationError` on missing.
- All imports at module top. No inline or deferred imports except `settings_customise_sources`.
- Docs first. Always.

## Env Symmetry

- Train, Eval, Serve use same env construction from EnvUnit + AssetUnit
- gym-trading-env default reward untouched
- Stop-loss and take-profit via per-step return check in eval/serve loops (not custom env wrapper)
- SB3 VecNormalize is the only enhancement layer
- SB3 logger writes to Env/Outputs/logs/
- Broker execution is a thin post-loop hook in IOServePhase only
- Gym env stays pure across sim/paper/live — broker_mode never touches the env

## Metric Normalization

- **Time:** minutes. 1 bar = 60 min.
- **Returns:** percentage. 0.5 = 0.5%.
- **Features:** bounded floats with `ge` / `le`.

## Derivable Reporting

- gym-trading-env `add_metric` registers fold-style lambdas on the env (Market Return, Position Changes)
- `save_for_render` persists full History to `Env/Outputs/render_logs/` at episode end
- `just render` launches the gym-trading-env Flask dashboard over persisted render logs
- No separate Report phase — reporting is derivable from env History + Output types

## File Responsibilities

| Location | Does | Does NOT |
|----------|------|----------|
| `Types/` | Plain BaseModel type definitions with Field descriptions | Logic, pydantic-settings |
| `Monads/` | IO phase logic + BaseSettings + default.json | Define types |
| `Env/Inputs/` | Ephemeral runtime reads: cache, credentials, external data | Source code, persisted artifacts |
| `Env/Outputs/` | Persisted phase artifacts: models, features, logs, render_logs, docs | Source code, ephemeral data |

## Modification Rules

- **Docs first.** Always.
- To change a parameter: edit the phase's `default.json`.
- To change bounds: edit the typed BaseModel in Types/.
- To add a phase: add Input + Output in Types/, add IO{X}Phase in Monads/, update frozen tables.
- Every phase has exactly: Input + Output + Monad + justfile entry.
