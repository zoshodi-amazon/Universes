"""CoComposeProductMeta [CoProduct] — Main observation metadata (7 fields). All bounded.

Expanded to hold validation detail (import health, field count, JSON fidelity)
and visualization detail (phases logged, series logged) — flattened from
CoIOValidatePhase and IOVisualizePhase into the Main phase observer.
"""

from pydantic import BaseModel, Field
from CoTypes.Comonad.Trace.default import TraceComonad


class CoComposeProductMeta(BaseModel):
    """CoComposeProductMeta [CoProduct] — Main observation trace + validation detail (7 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad, description="Coalgebraic observation cursor"
    )
    artifact_found: bool = Field(
        default=False, description="Whether a main artifact was found in StoreMonad"
    )
    schema_valid: bool = Field(
        default=False,
        description="Whether the artifact conforms to ComposeProductOutput schema",
    )
    imports_healthy: bool = Field(
        default=False,
        description="Whether all type modules imported without error",
    )
    field_counts_valid: bool = Field(
        default=False,
        description="Whether all types have <=7 fields",
    )
    json_fidelity: bool = Field(
        default=False,
        description="Whether all default.json files match their Settings schema",
    )
    n_phases_visualized: int = Field(
        default=0,
        ge=0,
        le=7,
        description="Number of phases logged to Rerun visualization (0 if disabled)",
    )
