"""MainHom [Hom] — Main phase config (4 params). All bounded.

Controls walk-forward windowing and optional Optuna optimization for the full
Discovery -> Ingest -> Feature -> (Train -> Eval)* pipeline.
Time in minutes.
"""
from pydantic import BaseModel, Field
from Types.Dependent.Optimize.default import OptimizeDependent


class MainHom(BaseModel):
    """MainHom [Hom] — Config for IOMainPhase: walk-forward windowing + optional optimization."""
    stride_min: int = Field(default=1440, ge=60, le=100_000, description="Step size between windows in minutes — 1440 = slide one day at a time")
    train_split_pct: float = Field(default=80.0, ge=10.0, le=95.0, description="Percentage of data used for training vs held-out evaluation")
    optimize: bool = Field(default=False, description="Enable Optuna hyperparameter search mode")
    optimize_config: OptimizeDependent = Field(default_factory=OptimizeDependent, description="Optuna search configuration (only used if optimize=True)")
