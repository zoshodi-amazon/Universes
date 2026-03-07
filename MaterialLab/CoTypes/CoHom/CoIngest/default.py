from __future__ import annotations

from pydantic import BaseModel, Field


class CoIngestHom(BaseModel):
    """[CoHom] — Ingest observation spec, dual of IngestHom."""

    check_file_exists: bool = Field(
        default=True,
        description="Verify ingested file exists on disk",
    )
    check_mesh_integrity: bool = Field(
        default=True,
        description="Verify mesh data is structurally intact",
    )
    check_watertight: bool = Field(
        default=True,
        description="Verify mesh is watertight (closed manifold)",
    )
    check_vertex_count: bool = Field(
        default=True,
        description="Verify vertex count is within acceptable range",
    )
