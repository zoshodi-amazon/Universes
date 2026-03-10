"""CoIngestProductOutput [CoProduct] — Ingest observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Ingest.Meta.default import CoIngestProductMeta


class CoIngestProductOutput(BaseModel):
    """CoIngestProductOutput [CoProduct] — What was observed about an ingest run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    data_present: bool = Field(
        default=False, description="Whether ingest blob exists on disk"
    )
    schema_valid: bool = Field(
        default=False, description="Whether blob deserializes to valid FrameInductive"
    )
    bars_sufficient: bool = Field(
        default=False, description="Whether n_bars meets minimum threshold"
    )
    meta: CoIngestProductMeta = Field(
        default_factory=CoIngestProductMeta,
        description="Observation metadata — trace cursor",
    )
