from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class GeometryProductOutput(BaseModel):
    """[Product] — Geometry phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    volume_mm3: float = Field(
        default=0.0,
        ge=0.0,
        le=1e12,
        description="Part volume in mm^3",
    )
    surface_area_mm2: float = Field(
        default=0.0,
        ge=0.0,
        le=1e12,
        description="Surface area in mm^2",
    )
    bounding_box_mm: str = Field(
        default="",
        min_length=0,
        max_length=64,
        description="WxHxD format",
    )
    operation_applied: str = Field(
        default="build",
        min_length=1,
        max_length=32,
        description="What operation was run",
    )
    export_path: str = Field(
        default="",
        min_length=0,
        max_length=512,
        description="Path to exported file",
    )
