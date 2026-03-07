"""MainProductMeta [Product] — Phase output meta extension for Main (pipeline).

Bound to Main/pipeline phase. Contains ObservabilityMonad + optimization results.
Sentinel values indicate non-optimized runs:
- best_lr = -1.0 means not optimized
- best_timesteps = -1 means not optimized
- best_win_rate_pct = -1.0 means not optimized
- n_completed = 0 means not optimized

io_study_path removed: IO paths belong in StoreMonad, not Product types. The
Optuna journal blob is stored via store.put("study_log", ...) and is retrievable
from the DB. Recording a filesystem path on the Product type violates the invariant
that types record what was computed, not where things are stored.
"""
from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class MainProductMeta(BaseModel):
    """MainProductMeta [Product] — Phase output meta extension for Main (5 fields)."""
    obs: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.pipeline),
        description="Observability data — errors, metrics, alarms, timing")
    best_lr: float = Field(default=-1.0, ge=-1.0, le=1.0,
        description="Learning rate of best trial (-1.0 if not optimized)")
    best_timesteps: int = Field(default=-1, ge=-1, le=100_000_000,
        description="Total timesteps of best trial (-1 if not optimized)")
    best_win_rate_pct: float = Field(default=-1.0, ge=-1.0, le=100.0,
        description="Win rate of best trial (-1.0 if not optimized)")
    n_completed: int = Field(default=0, ge=0, le=10_000,
        description="Number of Optuna trials completed (0 if not optimized)")
