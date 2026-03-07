from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class FabricationProductOutput(BaseModel):
    """[Product] — Fabrication phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    io_output_path: str = Field(
        default="",
        min_length=0,
        max_length=512,
        description="Path to generated G-code/toolpath",
    )
    layer_count: int = Field(
        default=0,
        ge=0,
        le=1_000_000,
        description="Total layers",
    )
    estimated_time_min: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Estimated print/machine time in minutes (sentinel -1.0 = not set)",
    )
    estimated_material_g: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Estimated material usage in grams (sentinel -1.0 = not set)",
    )
    support_volume_mm3: float = Field(
        default=0.0,
        ge=0.0,
        le=1e9,
        description="Support structure volume",
    )
