"""MachineSpecDependent [Dependent] — Machine spec parameterization, Liquid Crystal phase.

Parameterized manufacturing machine specification covering build volume,
nozzle geometry, positional resolution, and thermal limits. No optional
fields; sentinels used where absence must be representable.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class MachineSpecDependent(BaseModel):
    """[Dependent] — Machine spec parameterization, Liquid Crystal phase."""

    build_volume_x_mm: float = Field(
        default=250.0,
        ge=10.0,
        le=10000.0,
        description="Build volume X dimension in mm.",
    )
    build_volume_y_mm: float = Field(
        default=210.0,
        ge=10.0,
        le=10000.0,
        description="Build volume Y dimension in mm.",
    )
    build_volume_z_mm: float = Field(
        default=210.0,
        ge=10.0,
        le=10000.0,
        description="Build volume Z dimension in mm.",
    )
    nozzle_dia_mm: float = Field(
        default=0.4,
        ge=0.1,
        le=5.0,
        description="Nozzle diameter in mm.",
    )
    resolution_um: float = Field(
        default=50.0,
        ge=1.0,
        le=1000.0,
        description="XY resolution in micrometers.",
    )
    max_temp_c: float = Field(
        default=300.0,
        ge=100.0,
        le=1000.0,
        description="Max extruder/tool temperature in Celsius.",
    )
