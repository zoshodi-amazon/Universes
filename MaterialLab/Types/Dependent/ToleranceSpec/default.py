"""ToleranceSpecDependent [Dependent] — Tolerance spec parameterization, Liquid Crystal phase.

Parameterized tolerance specification covering linear accuracy, angular
accuracy, surface finish, and minimum feature sizes. No optional fields;
sentinels used where absence must be representable.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class ToleranceSpecDependent(BaseModel):
    """[Dependent] — Tolerance spec parameterization, Liquid Crystal phase."""

    linear_mm: float = Field(
        default=0.2,
        ge=0.001,
        le=10.0,
        description="Linear tolerance in mm.",
    )
    angular_deg: float = Field(
        default=0.5,
        ge=0.01,
        le=5.0,
        description="Angular tolerance in degrees.",
    )
    surface_finish_um: float = Field(
        default=50.0,
        ge=0.1,
        le=1000.0,
        description="Surface roughness Ra in micrometers.",
    )
    min_wall_mm: float = Field(
        default=0.8,
        ge=0.1,
        le=50.0,
        description="Minimum wall thickness in mm.",
    )
    min_clearance_mm: float = Field(
        default=0.3,
        ge=0.05,
        le=10.0,
        description="Minimum clearance between parts in mm.",
    )
