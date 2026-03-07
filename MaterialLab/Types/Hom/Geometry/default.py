"""GeometryHom [Hom] — Geometry phase input morphism, Liquid phase.

Geometry phase input controlling parametric CAD operations: script path,
operation type, export format, tessellation tolerance, and simplification.
No optional fields; sentinels used where absence must be representable
(io_script_path="" = use parametric defaults).
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class GeometryHom(BaseModel):
    """[Hom] — Geometry phase input morphism, Liquid phase."""

    io_script_path: Annotated[str, StringConstraints(min_length=0, max_length=512)] = (
        Field(
            default="",
            description="Path to CadQuery script; sentinel '' = use parametric defaults.",
        )
    )
    operation: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        default="build",
        description="Operation type: 'build', 'modify', or 'combine'.",
    )
    export_format: Annotated[str, StringConstraints(min_length=1, max_length=10)] = (
        Field(
            default="step",
            description="Output format (references CadFormatInductive), e.g. 'step'.",
        )
    )
    tessellation_tol_mm: float = Field(
        default=0.1,
        ge=0.001,
        le=10.0,
        description="Tessellation tolerance in mm for mesh export.",
    )
    simplify: bool = Field(
        default=False,
        description="Simplify geometry by removing small features.",
    )
