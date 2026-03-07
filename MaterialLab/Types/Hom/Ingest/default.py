"""IngestHom [Hom] — Ingest phase input morphism, Liquid phase.

Ingest phase input controlling CAD file ingestion: file path, expected
format, mesh validation and repair flags, and unit scaling. No optional
fields; all fields carry concrete defaults or are required.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class IngestHom(BaseModel):
    """[Hom] — Ingest phase input morphism, Liquid phase."""

    io_file_path: Annotated[str, StringConstraints(min_length=1, max_length=512)] = (
        Field(
            description="Absolute or relative path to the CAD file to ingest.",
        )
    )
    io_format: Annotated[str, StringConstraints(min_length=1, max_length=10)] = Field(
        default="step",
        description="Expected file format (references CadFormatInductive), e.g. 'step'.",
    )
    validate_mesh: bool = Field(
        default=True,
        description="Run mesh integrity validation after import.",
    )
    repair_mesh: bool = Field(
        default=False,
        description="Attempt automatic mesh repair if defects are found.",
    )
    units_scale: float = Field(
        default=1.0,
        ge=0.001,
        le=1000.0,
        description="Scale factor applied to imported geometry; 1.0 = file units are mm.",
    )
