from __future__ import annotations

from pydantic import BaseModel, Field


class CoGeometryHom(BaseModel):
    """[CoHom] — Geometry observation spec, dual of GeometryHom."""

    check_volume_positive: bool = Field(
        default=True,
        description="Verify computed volume is positive",
    )
    check_bounding_box: bool = Field(
        default=True,
        description="Verify bounding box is within expected bounds",
    )
    check_export_valid: bool = Field(
        default=True,
        description="Verify exported geometry file is valid",
    )
    render_3d: bool = Field(
        default=False,
        description="Enable 3D geometry rendering",
    )
