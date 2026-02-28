"""OptimizeInput [Liquid] — Optimize phase config (7 params). All bounded."""
from enum import Enum
from pydantic import BaseModel, Field


class ObjectiveMetric(str, Enum):
    """Optimization target metric — what Optuna trials maximize."""
    win_rate_pct = "win_rate_pct"
    avg_return_pct = "avg_return_pct"


class OptimizeInput(BaseModel):
    """OptimizeInput [Liquid] — Config for Optuna hyperparameter search over walk-forward trials."""
    n_trials: int = Field(default=20, ge=1, le=10_000, description="Number of Optuna optimization trials to run")
    n_parallel: int = Field(default=1, ge=1, le=16, description="Parallel trial workers — uses JournalStorage for safe concurrency")
    objective_metric: ObjectiveMetric = Field(default=ObjectiveMetric.win_rate_pct, description="Metric to maximize — win rate or average return percentage")
    search_space_lr_min: float = Field(default=1e-5, ge=1e-8, le=1.0, description="Lower bound of learning rate search range (log scale)")
    search_space_lr_max: float = Field(default=1e-2, ge=1e-8, le=1.0, description="Upper bound of learning rate search range (log scale)")
    search_space_timesteps_min: int = Field(default=10_000, ge=100, le=100_000_000, description="Lower bound of total training timesteps search range")
    search_space_timesteps_max: int = Field(default=200_000, ge=100, le=100_000_000, description="Upper bound of total training timesteps search range")
