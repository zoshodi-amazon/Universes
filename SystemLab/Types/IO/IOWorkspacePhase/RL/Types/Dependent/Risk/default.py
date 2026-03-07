"""RiskDependent [Dependent] — Per-step risk gate parameters (2 fields).

Liquid Crystal phase — parameterised risk thresholds shared across
Train (via EnvDependent), Eval, and Serve phases.
stop_loss_pct is negative by convention (loss).
profit_threshold_pct is positive (gain).
"""
from pydantic import BaseModel, Field


class RiskDependent(BaseModel):
    """RiskDependent [Dependent] — Stop-loss and take-profit thresholds for risk gating (2 fields)."""
    stop_loss_pct: float = Field(default=-2.0, ge=-100.0, le=0.0,
        description="Per-step stop-loss trigger as negative percentage of portfolio — e.g. -2.0 = exit at 2% loss")
    profit_threshold_pct: float = Field(default=0.5, ge=0.0, le=100.0,
        description="Take-profit trigger as positive percentage return on portfolio — e.g. 0.5 = exit at 0.5% gain")
