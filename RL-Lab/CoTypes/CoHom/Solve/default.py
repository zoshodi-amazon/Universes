"""CoSolveHom [CoHom] — Train phase observation spec (4 fields). All bounded.

Liquid-dual — observation specification parallel to SolveHom.
"""

from pydantic import BaseModel, Field


class CoSolveHom(BaseModel):
    """CoSolveHom [CoHom] — What to verify about a train run (4 fields)."""

    model_saved: bool = Field(
        default=True,
        description="Check that model.zip was saved to StoreMonad blob dir",
    )
    normalize_saved: bool = Field(
        default=True,
        description="Check that VecNormalize stats were saved alongside model",
    )
    timesteps_completed: bool = Field(
        default=True,
        description="Check that budget were completed without crash",
    )
    reward_finite: bool = Field(
        default=True,
        description="Check that final_reward is a finite number (not NaN/Inf)",
    )
