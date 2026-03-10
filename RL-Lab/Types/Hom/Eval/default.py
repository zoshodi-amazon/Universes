"""EvalHom [Hom] — Eval phase config (1 field). All bounded.

profit_threshold_pct moved to ConstraintDependent (shared with ProjectHom).
stop_loss_pct is on ConstraintDependent (composed via ExecutionDependent).

Fields satisfy Independence, Completeness, Locality:
- horizon_min: evaluation window length — the only eval-specific axis
"""
from pydantic import BaseModel, Field


class EvalHom(BaseModel):
    """EvalHom [Hom] — Config for out-of-sample model evaluation."""
    horizon_min: int = Field(default=1440, ge=60, le=100_000,
        description="Evaluation window length in minutes — 1440 = one trading day")
