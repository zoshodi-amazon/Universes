"""CoIngestProductMeta [CoProduct] — Ingest observation metadata (3 fields). All bounded."""

from pydantic import BaseModel, Field
from CoTypes.Comonad.Trace.default import TraceComonad


class CoIngestProductMeta(BaseModel):
    """CoIngestProductMeta [CoProduct] — Ingest observation trace (3 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad, description="Coalgebraic observation cursor"
    )
    artifact_found: bool = Field(
        default=False, description="Whether an ingest artifact was found in StoreMonad"
    )
    blob_readable: bool = Field(
        default=False, description="Whether the pickle blob can be read without error"
    )
