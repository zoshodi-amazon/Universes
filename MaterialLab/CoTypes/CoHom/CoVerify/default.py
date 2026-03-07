from __future__ import annotations

from pydantic import BaseModel, Field


class CoVerifyHom(BaseModel):
    """[CoHom] — Verify observation spec, dual of VerifyHom."""

    check_dimensions_ok: bool = Field(
        default=True,
        description="Verify physical dimensions are within tolerance",
    )
    check_tolerances_ok: bool = Field(
        default=True,
        description="Verify all tolerances are satisfied",
    )
    check_printability_ok: bool = Field(
        default=True,
        description="Verify design is printable as specified",
    )
    render_deviations: bool = Field(
        default=False,
        description="Enable deviation plot rendering",
    )
