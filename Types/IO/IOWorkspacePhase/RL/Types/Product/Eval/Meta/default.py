"""EvalProductMeta [Product] — Phase output meta extension for Eval.

Bound to Eval phase. Contains ObservabilityMonad + eval-specific audit fields.
"""
from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class EvalProductMeta(BaseModel):
    """EvalProductMeta [Product] — Phase output meta extension for Eval (6 fields)."""
    obs: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.eval),
        description="Observability data — errors, metrics, alarms, timing")
    steps_taken: int = Field(default=0, ge=0, le=10_000_000,
        description="Environment steps taken during eval")
    stop_loss_triggered: bool = Field(default=False,
        description="Whether stop-loss ended the episode")
    take_profit_triggered: bool = Field(default=False,
        description="Whether take-profit ended the episode")
    max_drawdown_pct: float = Field(default=0.0, ge=-100.0, le=100.0,
        description="Maximum drawdown during evaluation")
    position_changes: int = Field(default=0, ge=0, le=100_000,
        description="Number of position changes during eval")
