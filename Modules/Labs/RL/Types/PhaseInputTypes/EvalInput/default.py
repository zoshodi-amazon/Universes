"""EvalInput [Liquid] — Eval phase config (2 params). All bounded."""
from pydantic import BaseModel, Field


class EvalInput(BaseModel):
    """EvalInput [Liquid] — Config for out-of-sample model evaluation with stop-loss and take-profit."""
    forward_steps_min: int = Field(default=1440, ge=60, le=100_000, description="Evaluation window length in minutes — 1440 = one trading day")
    profit_threshold_pct: float = Field(default=0.5, ge=0.0, le=100.0, description="Take-profit trigger as percentage return on portfolio")
