"""ServeInputHom [Hom] — Composite input bundle for IOServePhase (2 fields).

Liquid phase — bundles the per-bar feature engineering and ingest Hom types
needed by the serve loop. Extracted to keep IOServePhase Settings at <=7 fields
after the store field was lifted from RunIdentity to the IO layer.

Parallel to PipelineHom (which bundles sub-phase Hom types for IOMainPhase).
"""

from pydantic import BaseModel, Field

from Types.Hom.Feature.default import FeatureHom
from Types.Hom.Ingest.default import IngestHom


class ServeInputHom(BaseModel):
    """ServeInputHom [Hom] — Feature + Ingest Hom bundle for live serving (2 fields)."""

    feature: FeatureHom = Field(
        default_factory=FeatureHom,
        description="Feature config — wavelet, trend indicators, regime threshold",
    )
    ingest: IngestHom = Field(
        default_factory=IngestHom,
        description="Ingest config — lookback period, warmup bars",
    )
