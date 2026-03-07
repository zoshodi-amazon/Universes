from __future__ import annotations

from pydantic import BaseModel, Field


class CoFabricationHom(BaseModel):
    """[CoHom] — Fabrication observation spec, dual of FabricationHom."""

    check_output_exists: bool = Field(
        default=True,
        description="Verify fabrication output artifact exists",
    )
    check_layer_count: bool = Field(
        default=True,
        description="Verify layer count is within expected range",
    )
    check_estimated_time: bool = Field(
        default=True,
        description="Verify estimated fabrication time is reasonable",
    )
    render_toolpath: bool = Field(
        default=False,
        description="Enable toolpath rendering",
    )
