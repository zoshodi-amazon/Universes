"""VerifyHom [Hom] — Verify phase input morphism, Liquid phase.

Verify phase input controlling quality checks: dimensional analysis,
printability checks, tolerance conformance, overhang threshold, and
reference run comparison. No optional fields; sentinels used where absence
must be representable (reference_run_id="" = no comparison).
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class VerifyHom(BaseModel):
    """[Hom] — Verify phase input morphism, Liquid phase."""

    check_dimensions: bool = Field(
        default=True,
        description="Run dimensional analysis against design spec.",
    )
    check_printability: bool = Field(
        default=True,
        description="Check for overhangs, support needs, and bridging issues.",
    )
    check_tolerances: bool = Field(
        default=True,
        description="Check GD&T conformance against ToleranceSpecDependent.",
    )
    max_overhang_deg: float = Field(
        default=45.0,
        ge=0.0,
        le=90.0,
        description="Maximum overhang angle in degrees before generating a warning.",
    )
    reference_run_id: Annotated[str, StringConstraints(min_length=0, max_length=8)] = (
        Field(
            default="",
            description="Run ID to compare against (references RunIdentity); sentinel '' = no comparison.",
        )
    )
