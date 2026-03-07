"""PrintProfileDependent [Dependent] — Print profile parameterization, Liquid Crystal phase.

Parameterized print profile covering layer geometry, fill density, speed,
and temperature settings. No optional fields; sentinels used where absence
must be representable.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class PrintProfileDependent(BaseModel):
    """[Dependent] — Print profile parameterization, Liquid Crystal phase."""

    layer_height_mm: float = Field(
        default=0.2,
        ge=0.01,
        le=1.0,
        description="Layer height in mm.",
    )
    infill_pct: float = Field(
        default=20.0,
        ge=0.0,
        le=100.0,
        description="Infill percentage.",
    )
    print_speed_mm_s: float = Field(
        default=60.0,
        ge=1.0,
        le=500.0,
        description="Print speed in mm/s.",
    )
    nozzle_temp_c: float = Field(
        default=210.0,
        ge=150.0,
        le=500.0,
        description="Nozzle temperature in Celsius.",
    )
    bed_temp_c: float = Field(
        default=60.0,
        ge=0.0,
        le=200.0,
        description="Bed temperature in Celsius.",
    )
    wall_count: int = Field(
        default=3,
        ge=1,
        le=20,
        description="Number of wall/perimeter lines.",
    )
