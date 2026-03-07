from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class IngestProductOutput(BaseModel):
    """[Product] — Ingest phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    io_file_path: str = Field(
        min_length=1,
        max_length=512,
        description="Ingested file path",
    )
    format_detected: str = Field(
        min_length=1,
        max_length=10,
        description="Detected format",
    )
    vertex_count: int = Field(
        default=0,
        ge=0,
        le=100_000_000,
        description="Mesh vertices",
    )
    face_count: int = Field(
        default=0,
        ge=0,
        le=100_000_000,
        description="Mesh faces",
    )
    is_watertight: bool = Field(
        default=False,
        description="Mesh watertight status",
    )
