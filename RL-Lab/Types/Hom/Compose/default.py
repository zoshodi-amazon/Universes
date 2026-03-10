"""ComposeHom [Hom] — Main phase config (4 params). All bounded.

Controls walk-forward windowing and optional Optuna optimization for the full
Discovery -> Ingest -> Feature -> (Train -> Eval)* pipeline.
Time in minutes.
"""

from pydantic import BaseModel, Field
from Types.Dependent.Search.default import SearchDependent


class ComposeHom(BaseModel):
    """ComposeHom [Hom] — Config for IOComposePhase: walk-forward windowing + optional optimization."""

    stride_min: int = Field(
        default=1440,
        ge=60,
        le=100_000,
        description="Step size between windows in minutes — 1440 = slide one day at a time",
    )
    solve_split_pct: float = Field(
        default=80.0,
        ge=10.0,
        le=95.0,
        description="Percentage of data used for training vs held-out evaluation",
    )
    search: bool = Field(
        default=False, description="Enable Optuna hyperparameter search mode"
    )
    search_fiber: SearchDependent = Field(
        default_factory=SearchDependent,
        description="Optuna search configuration (only used if search=True)",
    )
