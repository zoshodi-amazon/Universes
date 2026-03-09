"""CoEvalProductMeta [CoProduct] — Eval observation metadata (3 fields). All bounded."""

from pydantic import BaseModel, Field
from CoTypes.Comonad.Trace.default import TraceComonad


class CoEvalProductMeta(BaseModel):
    """CoEvalProductMeta [CoProduct] — Eval observation trace (3 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad, description="Coalgebraic observation cursor"
    )
    artifact_found: bool = Field(
        default=False, description="Whether an eval artifact was found in StoreMonad"
    )
    schema_valid: bool = Field(
        default=False,
        description="Whether the artifact conforms to EvalProductOutput schema",
    )
