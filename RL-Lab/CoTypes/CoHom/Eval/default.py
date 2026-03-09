"""CoEvalHom [CoHom] — Eval phase observation spec (5 fields). All bounded.

Liquid-dual — observation specification parallel to EvalHom.
Render dashboard launch absorbed from dissolved ana-render justfile command.
"""

from pydantic import BaseModel, Field


class CoEvalHom(BaseModel):
    """CoEvalHom [CoHom] — What to verify about an eval run (5 fields)."""

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
    launch_renderer: bool = Field(
        default=False,
        description="Launch gym-trading-env Flask render dashboard if render logs present",
    )
