# RL Trading Sandbox

Autonomous self-hosted quant RL lab. Asset-agnostic (stocks, crypto, forex).

## Synopsis

```
just discover
just ingest
just feature
just train
just eval
just infer
just pipeline
just optimize
```

## Core Goal

- Asset-agnostic via AssetUnit (stocks/crypto/forex, trade hours, holidays)
- Trend-based discovery via yfinance screener + ADX regime filtering (highest-ADX ticker chosen)
- Wavelet (db4) on all OHLCV channels for smooth input geometry
- SB3 VecNormalize for obs/reward (only enhancement layer)
- gym-trading-env default reward untouched, per-step stop-loss/take-profit in eval/infer
- Walk-forward batch backtest via IOPipelinePhase
- Train/infer env symmetry: broker_mode toggles sim/paper/live

## Frozen Phase Chain

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve
```

## Matter-Phase Type System

Types follow the free ⊣ forgetful adjunction, mapped to phases of matter:

| Phase | Layer | Description |
|-------|-------|-------------|
| **Solid** | UnitTypes | Irreducible basis vectors, maximally constrained, shared across ≥2 phases |
| **Liquid** | PhaseInputTypes | Bounded configs that flow into phases, structured but reshapable |
| **Gas** | PhaseOutputTypes | Computed artifacts, phase results expanding outward |
| **Plasma** | Monads/Settings | Free composition layer, IO boundary where types get composed from JSON/CLI |

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

## Architecture

```
Sandbox/RL/
├── pyproject.toml
├── justfile
├── README.md
├── AGENTS.md
├── Types/
│   ├── UnitTypes/           # [Solid] Irreducible representations (basis vectors)
│   │   ├── AssetUnit/
│   │   ├── RunUnit/
│   │   ├── EnvUnit/
│   │   └── ErrorUnit/
│   ├── PhaseInputTypes/     # [Liquid] Phase input configs
│   │   ├── DiscoveryInput/
│   │   ├── IngestInput/
│   │   ├── FeatureInput/
│   │   ├── TrainInput/
│   │   ├── EvalInput/
│   │   ├── ServeInput/
│   │   ├── PipelineInput/
│   │   └── OptimizeInput/
│   └── PhaseOutputTypes/    # [Gas] Phase output artifacts
│       ├── DiscoveryOutput/
│       ├── IngestOutput/
│       ├── FeatureOutput/
│       ├── TrainOutput/
│       ├── EvalOutput/
│       ├── ServeOutput/
│       ├── PipelineOutput/
│       └── OptimizeOutput/
├── Env/
│   ├── cache/
│   ├── output/
│   └── arch/
└── Monads/                  # [Plasma] IO phase type constructors (each with own BaseSettings + default.json)
    ├── IODiscoveryPhase/
    ├── IOIngestPhase/
    ├── IOFeaturePhase/
    ├── IOTrainPhase/
    ├── IOEvalPhase/
    ├── IOServePhase/
    ├── IOPipelinePhase/
    └── IOOptimizePhase/
```

## Frozen UnitTypes

| Unit | Fields (<=7) |
|------|--------------|
| AssetUnit | asset_type, io_ticker, interval_min, trade_start_min, trade_end_min, holidays |
| RunUnit | run_id, run_ts, seed, name, output_dir, status, verbose |
| EnvUnit | initial_value, fees_pct, borrow_rate_pct, positions, broker_mode, io_broker_key, stop_loss_pct |

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

## Type Invariants

- <=7 per type. No exceptions.
- Every field has `Field(description=...)`. Types are documentation.
- Every field bounded. No unbounded types. No Optional/None. No placeholders.
- Fields must be orthogonal. Derived metrics are folds over results, not stored fields.
- No dropna, no NaN, no emojis, no print in Monads, no ad-hoc overrides.
- No magic numbers in Monads. Config is single source of truth.
- No inline comments in Monads. Documentation lives in types and module docstrings.
- Every Monad run() wraps IO in try/except, returns typed ErrorUnit on failure. Exceptions are typed fixpoints.
- Every env lifecycle wrapped in try/finally for cleanup.
- No unvalidated io_ path loads. Check file exists before read.
- No empty DataFrame propagation. Validate len(df) > 0 at phase entry.
- `io_` prefix for external required inputs, `ValidationError` on missing.
- All imports at module top. No inline or deferred imports except `settings_customise_sources`.
- Docs first. Always.

## Dependencies

```
gymnasium, gym-trading-env, stable-baselines3, yfinance,
PyWavelets, pandas-ta, matplotlib, pydantic, pydantic-settings,
optuna, alpaca-py
```

## Broker Integration

- **Sim mode** (default): gym-trading-env backtest only, no external API calls
- **Paper mode**: identical gym env + post-loop Alpaca order submission
- **Live mode**: same as paper, pointed at live Alpaca endpoint
- Gym env stays pure across all modes — broker layer is a thin post-loop hook
- API keys stored in `Env/.env` (gitignored), loaded via pydantic-settings
- Setup: copy `Env/.env.example` → `Env/.env`, fill in Alpaca keys
- Activate: `just infer --env.broker_mode paper`

## Period Normalization

- `period` in IngestInput is specified in trading days (e.g. `60d` = 60 trading days)
- IOIngestPhase normalizes to calendar days based on asset type at the IO boundary:
  - **stock/forex**: ×7/5 (weekends excluded) — 60 trading days → 84 calendar days
  - **crypto**: ×1 (24/7 markets) — 60 trading days → 60 calendar days

## UX-Paths

Orthogonal minimal generating set of questions across 5 concerns.
Each maps to a Record field (stored) or a fold over results (derived).
The union closes the full capability space. 20 questions total.

### Alpha -- strategy edge

| ID | Question | Source | Type |
|----|----------|--------|------|
| A1 | What is the win rate? | PipelineOutput.win_rate_pct | stored* |
| A2 | What is the expectancy? | fold: mean(wins) * win_rate - mean(losses) * loss_rate | derived |
| A3 | What is the Sharpe ratio? | fold: mean(returns) / std(returns) over results | derived |
| A4 | Is strategy better than buy-and-hold? | gym-trading-env Market Return via add_metric | derivable from env |

### Risk -- downside bounded

| ID | Question | Source | Type |
|----|----------|--------|------|
| R1 | What is the max drawdown? | fold: min(cumulative returns) over results | derived |
| R2 | Was stop-loss triggered? | EvalOutput.portfolio_return_pct <= EnvUnit.stop_loss_pct | derived |
| R3 | Was take-profit hit? | EvalOutput.threshold_met | stored* |
| R4 | What is the position exposure? | EvalOutput.position | stored |

### Execution -- trades correct

| ID | Question | Source | Type |
|----|----------|--------|------|
| X1 | What position is held? | InferOutput.position_taken | stored |
| X2 | What was the fees impact? | EnvUnit.fees_pct * n_trades (from position changes) | derived |
| X3 | How many trades were made? | fold: sum(diff(positions) != 0) over env history | derivable from env |
| X4 | Is the model fresh? | InferOutput.model_age_min | stored |

### Data -- input trustworthy

| ID | Question | Source | Type |
|----|----------|--------|------|
| D1 | Is the data current? | IngestOutput.io_end_date | stored |
| D2 | Are there enough bars? | IngestOutput.n_bars | stored |
| D3 | Is feature geometry stable? | FeatureOutput.n_static_features + bounded fields | stored |
| D4 | Is the asset trending? | DiscoveryOutput.n_qualifying > 0 | stored |

### Ops -- system healthy

| ID | Question | Source | Type |
|----|----------|--------|------|
| O1 | Did the pipeline complete? | PipelineOutput.status | stored |
| O2 | How long did it take? | PipelineOutput.duration_s | stored |
| O3 | Were there errors? | PipelineOutput.errors | stored |
| O4 | Are artifacts persisted? | fold: len(PipelineOutput.results) | derived |

### Closure verification

Every user question maps to a UX-Path:

| User question | Path |
|---------------|------|
| What assets should I trade? | D4 |
| Do I have enough data? | D2 |
| Are my features correct? | D3 |
| Did training work? | TrainOutput.final_reward |
| Would this have been profitable? | A1, R1-R4 |
| What position should I take? | X1 |
| Is my model stale? | X4 |
| What is my win rate? | A1 |
| What are the best hyperparams? | OptimizeOutput |
| Is my risk bounded? | R1-R3 |
| Did anything fail? | O1, O3 |

20 questions, 5 concerns, all answerable from Records or folds. No question outside this set.

## Learnings

- **Phase audit closure before impl.** Every observable in the UX-Path metric space must map to an exact typed field, a producing phase, a consuming phase, and an enforcement point — before writing any Monad logic. The 20 UX-Paths define the minimal orthogonal generating set. If any observable is "stored but not enforced," that's a gap. Property: for every stored observable, there exists a phase that validates it as a pre-condition before the next phase acts. No exceptions.
- **Template the phase chain as a functor, not a pipeline.** Each phase is a morphism `Input × UnitTypes → Output`. Gaps appear when a Gas output from phase N isn't validated as a Liquid pre-condition in phase N+1. The synthetic geometry: every Gas field that gates a downstream action must have a corresponding Liquid bound that the consuming Monad checks.
- **5m bars >> 1h bars for stop-loss/take-profit.** At 1h granularity, single-bar gaps routinely blew past the -2% stop-loss (worst: -15.12%). At 5m, losses cap near -2.1% to -2.3%. Take-profit exits tighten from +10% overshoot to clean +0.5-0.9% exits.
- **Optuna parallel trials need JournalStorage.** SQLite storage corrupts under `n_jobs > 1` (truncated pickle, unclosed connections). `JournalFileBackend` with file-based locking is the correct backend. Each trial also needs a unique `run_id` to avoid output file collisions.
- **More timesteps ≠ better generalization.** 100k vs 500k at 1h showed similar win rates (27%). 300k at 5m hit 72.73%. The interval granularity mattered more than raw training steps.
- **Dynamic discovery changes the game.** Hardcoded AAPL gave 27% win rate. Screener-driven discovery (highest ADX) found INTC, NVO, MSFT, AMD across runs — each with different market regimes. AMD at 300k/5m hit 72.73%.
