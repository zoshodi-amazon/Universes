"""SearchDependent [Dependent] — Optuna hyperparameter search configuration (7 fields). All bounded.

Shared across IOComposePhase optimize mode. Defines search space bounds for learning rate and timesteps.
Cross-field validators enforce lr_min < lr_max and timesteps_min < timesteps_max.

Fields satisfy Independence, Completeness, Locality:
- n_trials:                    trial budget — independent axis
- n_parallel:                  parallelism — independent of n_trials
- objective_metric:            what to maximise — independent axis
- search_space_lr_min/max:     learning rate search range bounds — pair, validated
- search_space_timesteps_min/max: timestep search range bounds — pair, validated
"""
from enum import Enum
from pydantic import BaseModel, Field, model_validator


class ObjectiveMetric(str, Enum):
    """Optimization target metric — what Optuna trials maximize."""
    win_rate_pct = "win_rate_pct"
    avg_return_pct = "avg_return_pct"


class SearchDependent(BaseModel):
    """SearchDependent [Dependent] — Optuna search parameters for hyperparameter optimization."""
    n_trials: int = Field(default=20, ge=1, le=10_000,
        description="Number of Optuna optimization trials to run")
    n_parallel: int = Field(default=1, ge=1, le=16,
        description="Parallel trial workers — uses JournalStorage for safe concurrency")
    objective_metric: ObjectiveMetric = Field(default=ObjectiveMetric.win_rate_pct,
        description="Metric to maximize — win rate or average return percentage")
    search_space_lr_min: float = Field(default=1e-5, ge=1e-8, le=1.0,
        description="Lower bound of learning rate search range (log scale)")
    search_space_lr_max: float = Field(default=1e-2, ge=1e-8, le=1.0,
        description="Upper bound of learning rate search range (log scale)")
    search_space_timesteps_min: int = Field(default=10_000, ge=100, le=100_000_000,
        description="Lower bound of total training timesteps search range")
    search_space_timesteps_max: int = Field(default=200_000, ge=100, le=100_000_000,
        description="Upper bound of total training timesteps search range")

    @model_validator(mode="after")
    def _validate_ranges(self) -> "SearchDependent":
        if self.search_space_lr_min >= self.search_space_lr_max:
            raise ValueError(
                f"search_space_lr_min ({self.search_space_lr_min}) must be < "
                f"search_space_lr_max ({self.search_space_lr_max})"
            )
        if self.search_space_timesteps_min >= self.search_space_timesteps_max:
            raise ValueError(
                f"search_space_timesteps_min ({self.search_space_timesteps_min}) must be < "
                f"search_space_timesteps_max ({self.search_space_timesteps_max})"
            )
        return self
