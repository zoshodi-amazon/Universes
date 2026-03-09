"""CoMainHom [CoHom] — Main phase observation spec (4 fields). All bounded.

Liquid-dual — observation specification parallel to MainHom.
"""

from pydantic import BaseModel, Field


class CoMainHom(BaseModel):
    """CoMainHom [CoHom] — What to verify about a main pipeline run (4 fields)."""

    all_phases_completed: bool = Field(
        default=True,
        description="Check that discovery through eval all completed without fatal error",
    )
    windows_evaluated: bool = Field(
        default=True, description="Check that walk-forward windows were evaluated"
    )
    win_rate_computed: bool = Field(
        default=True,
        description="Check that win_rate_pct was computed from window results",
    )
    result_persisted: bool = Field(
        default=True,
        description="Check that final MainProductOutput was persisted to StoreMonad",
    )
