"""CoDiscoveryProductMeta [CoProduct] — Discovery observation metadata (3 fields). All bounded."""

from pydantic import BaseModel, Field
from CoTypes.Comonad.Trace.default import TraceComonad


class CoDiscoveryProductMeta(BaseModel):
    """CoDiscoveryProductMeta [CoProduct] — Discovery observation trace (3 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad, description="Coalgebraic observation cursor"
    )
    artifact_found: bool = Field(
        default=False,
        description="Whether a discovery artifact was found in StoreMonad",
    )
    schema_valid: bool = Field(
        default=False,
        description="Whether the artifact conforms to DiscoveryProductOutput schema",
    )
