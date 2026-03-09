"""CoEvalHom [CoHom] — Eval phase observation spec (4 fields). All bounded.

Liquid-dual — observation specification parallel to EvalHom.
"""

from pydantic import BaseModel, Field


class CoEvalHom(BaseModel):
    """CoEvalHom [CoHom] — What to verify about an eval run (4 fields)."""

    model_loaded: bool = Field(
        default=True,
        description="Check that model + normalize were loaded from StoreMonad",
    )
    episode_completed: bool = Field(
        default=True, description="Check that the eval episode ran to completion"
    )
    risk_gates_applied: bool = Field(
        default=True,
        description="Check that stop-loss and take-profit were evaluated per step",
    )
    render_logs_saved: bool = Field(
        default=True,
        description="Check that render logs were written for dashboard visualization",
    )
