"""ArtifactRow [Monad] — Single artifact record returned from StoreMonad queries (6 fields).

Plasma phase — typed witness for a stored artifact's metadata.
Separated from StoreMonad to satisfy 1-type-per-file invariant.

Fields satisfy Independence, Completeness, Locality:
- session_id:        identifies which run produced this artifact
- phase:         identifies which phase produced it
- artifact_type: kind discriminator (e.g. 'model', 'features', 'normalize')
- blob_path:     filesystem location of the binary blob
- metadata_json: full ProductOutput serialized as JSON
- created_at:    ISO timestamp of when the artifact was written
"""

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class ArtifactRow(BaseModel):
    """ArtifactRow [Monad] — Single row returned from StoreMonad.get() / .latest() (6 fields)."""

    session_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        description="Run identifier that produced this artifact"
    )
    phase: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        description="Phase name that produced this artifact"
    )
    artifact_type: Annotated[str, StringConstraints(min_length=1, max_length=64)] = (
        Field(
            description="Artifact kind — e.g. 'ingest', 'model', 'normalize', 'features', 'discovery'"
        )
    )
    blob_path: Annotated[str, StringConstraints(min_length=0, max_length=512)] = Field(
        default="",
        description="Absolute or relative path to binary blob — empty for metadata-only artifacts",
    )
    metadata_json: Annotated[str, StringConstraints(min_length=2)] = Field(
        default="{}",
        description="Full ProductOutput model_dump_json() for this artifact",
    )
    created_at: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        description="ISO timestamp when this artifact was written"
    )
