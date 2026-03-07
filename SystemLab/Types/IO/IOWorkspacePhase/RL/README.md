# RL Trading Sandbox

Autonomous self-hosted quant RL lab. Asset-agnostic (stocks, crypto, forex).

## Synopsis

```
just discover    # Phase 1 (BEC): Find trending assets
just ingest      # Phase 2 (Crystalline): Download OHLCV data
just feature     # Phase 3 (Liquid Crystal): Wavelet + indicators
just train       # Phase 4 (Liquid): RL model training
just eval        # Phase 5 (Gas): Out-of-sample evaluation
just serve       # Phase 6 (Plasma): Live serving with broker
just main        # Phase 7 (QGP): Full pipeline
just render <run_id>  # Render dashboard for a specific run
just tail        # Observer: tail OpenCode SSE event stream
just visualize   # Observer: Rerun multi-modal run visualization
```

## Core Goal

- Asset-agnostic via AssetIdentity (stocks/crypto/forex, trade hours, holidays)
- Trend-based discovery via yfinance screener + ADX regime filtering (highest-ADX ticker chosen)
- Wavelet (db4) on all OHLCV channels for smooth input geometry
- SB3 VecNormalize for obs/reward (only enhancement layer)
- gym-trading-env default reward untouched, per-step stop-loss/take-profit in eval/serve
- Walk-forward batch backtest via IOMainPhase
- Optional Optuna optimization via `just main --main.optimize true`
- Train/eval/serve env symmetry: broker_mode toggles sim/paper/live

## Frozen Phase Chain (7 Phases)

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve -> Main
```

## Matter-Phase Type System

The 7 phases map to states of matter, from coldest (inner core) to hottest (atmosphere):

| # | Matter | Phase | IO Executor | Type Theory | Intuition |
|---|--------|-------|-------------|-------------|-----------|
| 1 | BEC | Discovery | IODiscoveryPhase | Unit (⊤) | "What universe exists?" |
| 2 | Crystalline | Ingest | IOIngestPhase | Inductive (ADT) | "What data structure?" |
| 3 | Liquid Crystal | Feature | IOFeaturePhase | Dependent type | "What geometry?" |
| 4 | Liquid | Train | IOTrainPhase | Function (A → B) | "What transformation?" |
| 5 | Gas | Eval | IOEvalPhase | Product/Sum | "What outcomes?" |
| 6 | Plasma | Serve | IOServePhase | Monad (M A) | "What effects?" |
| 7 | QGP | Main | IOMainPhase | IO | "Deploy everything" |

The fractal property: this structure recurses at every level.

## 1:1 Phase Mapping

Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry. No exceptions.

| Phase | Hom (input) | ProductOutput | IO Executor | justfile |
|-------|-------------|---------------|-------------|----------|
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `ingest` |
| Feature | FeatureHom | FeatureProductOutput | IOFeaturePhase | `feature` |
| Train | TrainHom | TrainProductOutput | IOTrainPhase | `train` |
| Eval | EvalHom | EvalProductOutput | IOEvalPhase | `eval` |
| Serve | ServeHom | ServeProductOutput | IOServePhase | `serve` |
| Main | MainHom | MainProductOutput | IOMainPhase | `main` |

## Architecture

```
RL/
├── pyproject.toml
├── justfile                       # [QGP] Single IO boundary — all phase invocations
├── README.md
├── AGENTS.md
├── Types/
│   ├── Identity/                  # [BEC] Terminal objects — Asset, Run (one canonical inhabitant)
│   ├── Inductive/                 # [Crystalline] Sum types / ADTs — OHLCV, Screener, TickerInfo, Algo
│   ├── Dependent/                 # [Liquid Crystal] Parameterized configs — Env, Risk, Liquidity, Alarm, Optimize
│   ├── Hom/                       # [Liquid] Phase inputs / morphisms
│   │   ├── Discovery/
│   │   ├── Ingest/
│   │   ├── Feature/
│   │   ├── Train/
│   │   ├── Eval/
│   │   ├── Serve/
│   │   └── Main/
│   ├── Product/                   # [Gas] Phase outputs + meta
│   │   ├── {Phase}/Output/
│   │   └── {Phase}/Meta/
│   ├── Monad/                     # [Plasma] Effect record types — Error, Metric, Alarm, Observability, Store
│   └── IO/                        # [QGP] IO executors — BaseSettings + run() + __main__
│       ├── IODiscoveryPhase/
│       ├── IOIngestPhase/
│       ├── IOFeaturePhase/
│       ├── IOTrainPhase/
│       ├── IOEvalPhase/
│       ├── IOServePhase/
│       └── IOMainPhase/
├── CoTypes/
│   ├── CoHom/                     # Observer configs (dual of Hom)
│   ├── CoProduct/                 # Observer outputs (dual of Product)
│   ├── Comonad/                   # Trace comonad (dual of ObservabilityMonad)
│   └── IO/                        # Observer executors
│       ├── IOTailPhase/
│       └── IOVisualizePhase/
├── store/
│   ├── .rl.db                     # SQLite artifact DB (auto-created)
│   └── blobs/                     # Binary artifacts — models, pickles, audit logs
│       └── {run_id}/
│           ├── {phase}_{type}.pkl / .zip / .json
│           ├── audit/             # Trade audit logs (JSONL)
│           └── render_logs/       # gym-trading-env history for Flask dashboard
└── store/docs/                    # Tracker markdown files
```

## Type Phase Mapping

Types are organized by their type-theoretic phase, which maps to matter states.
Phases are symmetry/Lie groups — types within the same phase share the same symmetry structure.

| # | Phase | Type Theory | Matter | Directory | Naming | Types |
|---|-------|-------------|--------|-----------|--------|-------|
| 1 | Identity | Unit (⊤) | BEC | `Types/Identity/` | `{Domain}Identity` | AssetIdentity, RunIdentity |
| 2 | Inductive | ADT | Crystalline | `Types/Inductive/` | `{Domain}Inductive` | OHLCVInductive, ScreenerInductive, ScreenerQuoteInductive, TickerInfoInductive, AlgoIdentity |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` | EnvDependent, RiskDependent, LiquidityDependent, AlarmDependent, OptimizeDependent |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` | DiscoveryHom, IngestHom, FeatureHom, TrainHom, EvalHom, ServeHom, MainHom |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` | {Phase}ProductOutput, {Phase}ProductMeta (×7 each) |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` | ErrorMonad, MetricMonad, AlarmMonad, ObservabilityMonad, StoreMonad |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` | IODiscoveryPhase … IOMainPhase (×7) |

## Product Types (Phase Outputs)

Each phase has Output + Meta under the same Product symmetry group:

| Phase | Output | Meta | Output Fields |
|-------|--------|------|---------------|
| Discovery | DiscoveryProductOutput | DiscoveryProductMeta | run_id, universe_size, qualifying_tickers, min_adx_used, meta |
| Ingest | IngestProductOutput | IngestProductMeta | run_id, io_ticker, interval_min, n_bars, meta |
| Feature | FeatureProductOutput | FeatureProductMeta | run_id, n_static_features, n_dynamic_features, n_valid_bars, feature_names, meta |
| Train | TrainProductOutput | TrainProductMeta | run_id, algo, total_timesteps, final_reward, meta |
| Eval | EvalProductOutput | EvalProductMeta | run_id, io_ticker, window_index, portfolio_return_pct, final_value, threshold_met, meta |
| Serve | ServeProductOutput | ServeProductMeta | run_id, io_ticker, n_bars_served, portfolio_return_pct, position_taken, status, meta |
| Main | MainProductOutput | MainProductMeta | run_id, n_windows, win_rate_pct, duration_s, status, results, meta |

## Type Invariants

- ≤7 fields per type. No exceptions.
- Every field has `Field(description=...)`. Types are documentation.
- Every field bounded. No unbounded types. No `Optional`/`None`. No placeholders.
- Sentinel values for "not set" (e.g., `-1.0`, `-1`, `""`)
- Fields must satisfy Independence, Completeness, Locality (coordinate chart invariant).
- No named type aliases — constraints inlined with `Annotated[..., StringConstraints(...)]` or `Field(ge=, le=)`.
- External data validated via Inductive types before crossing IO boundary.
- One type per `default.py` — no nested/hidden type classes.
- Fully qualified imports — explicitness over implicitness.
- Phases are symmetry groups — directory encodes phase.
- **Invariants are never traded away for convenience. No exceptions.**
- **Phase placement is determined solely by type theory** — Identity = `Unit (⊤)`, Inductive = ADTs/enums, etc.

## Dependencies

```
gymnasium, gym-trading-env, stable-baselines3, yfinance,
PyWavelets, pandas-ta, matplotlib, pydantic, pydantic-settings,
optuna, alpaca-py, sqlalchemy, rerun-sdk, sseclient-py
```

## Broker Integration

- **Sim mode** (default): gym-trading-env backtest only, no external API calls
- **Paper mode**: identical gym env + post-loop Alpaca order submission
- **Live mode**: same as paper, pointed at live Alpaca endpoint
- Gym env stays pure across all modes — broker layer is a thin post-loop hook
- API keys in `.env` at project root (gitignored), loaded via `load_dotenv()` in IOServePhase
- Setup: create `.env` with `ALPACA_API_KEY` and `ALPACA_SECRET_KEY`
- Activate: `just serve --env.broker_mode paper`

## Production Safeguards

IOServePhase includes:
- Stop-loss check (per-step return check)
- Take-profit check (exits on threshold)
- Model staleness check (rejects old models)
- Data freshness check (rejects stale data)
- Feature validation (ensures features exist)
- Graceful shutdown (SIGINT/SIGTERM handling)
- Audit logging (`store/blobs/{run_id}/audit/audit_{run_ts}_{run_id}.jsonl`)

## Optimization Mode

Run Optuna hyperparameter search:

```bash
just main --main.optimize true --main.optimize_config.n_trials 20
```

Searches over learning rate and timesteps within bounded search spaces.
