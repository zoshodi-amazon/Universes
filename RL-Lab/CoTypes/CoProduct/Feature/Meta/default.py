"""CoFeatureProductMeta [CoProduct] — Feature observation metadata (3 fields). All bounded."""

from pydantic import BaseModel, Field
from CoTypes.Comonad.Trace.default import TraceComonad


class CoFeatureProductMeta(BaseModel):
    """CoFeatureProductMeta [CoProduct] — Feature observation trace (3 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad, description="Coalgebraic observation cursor"
    )
    artifact_found: bool = Field(
        default=False, description="Whether a feature artifact was found in StoreMonad"
    )
    schema_valid: bool = Field(
        default=False,
        description="Whether the artifact conforms to FeatureProductOutput schema",
    )
