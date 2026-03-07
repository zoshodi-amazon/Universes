"""FabricationHom [Hom] — Fabrication phase input morphism, Liquid phase.

Fabrication phase input controlling slicer configuration: slicer engine,
support and raft toggles, part orientation on the build plate, and output
format. No optional fields; all fields carry concrete defaults.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class FabricationHom(BaseModel):
    """[Hom] — Fabrication phase input morphism, Liquid phase."""

    io_slicer: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        default="cura",
        description="Slicer engine identifier: 'cura', 'prusa', or 'custom'.",
    )
    support_enabled: bool = Field(
        default=True,
        description="Generate support structures for overhangs.",
    )
    raft_enabled: bool = Field(
        default=False,
        description="Generate raft or brim for bed adhesion.",
    )
    orientation_deg: float = Field(
        default=0.0,
        ge=0.0,
        le=360.0,
        description="Part rotation on build plate in degrees.",
    )
    output_format: Annotated[str, StringConstraints(min_length=1, max_length=10)] = (
        Field(
            default="gcode",
            description="Output format: 'gcode', '3mf', or 'svg'.",
        )
    )
