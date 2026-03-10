"""ConstraintDependent [Dependent] — Per-step risk gate parameters (3 fields).

Liquid Crystal phase — parameterised risk thresholds shared across
Train (via ExecutionDependent), Eval, and Serve phases.
stop_loss_pct is negative by convention (loss).
profit_threshold_pct is positive (gain).
max_drawdown_pct is negative by convention (peak-to-trough loss).
"""

from pydantic import BaseModel, Field


class ConstraintDependent(BaseModel):
    """ConstraintDependent [Dependent] — Stop-loss, take-profit, and max drawdown thresholds (3 fields)."""

    stop_loss_pct: float = Field(
        default=-2.0,
        ge=-100.0,
        le=0.0,
        description="Per-step stop-loss trigger as negative percentage of portfolio — e.g. -2.0 = exit at 2% loss",
    )
    profit_threshold_pct: float = Field(
        default=0.5,
        ge=0.0,
        le=100.0,
        description="Take-profit trigger as positive percentage return on portfolio — e.g. 0.5 = exit at 0.5% gain",
    )
    max_drawdown_pct: float = Field(
        default=-5.0,
        ge=-100.0,
        le=0.0,
        description="Max drawdown circuit breaker — e.g. -5.0 = flatten if portfolio drops 5% from peak",
    )
