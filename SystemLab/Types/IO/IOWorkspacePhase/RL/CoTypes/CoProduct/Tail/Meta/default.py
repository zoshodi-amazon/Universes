"""TailCoProductMeta [CoProduct] — Tail observer metadata (3 fields). All bounded.

Gas-dual phase — the dual of a ProductMeta type. Where ProductMeta records
what a phase produced (errors, alarms, timing), CoProductMeta records what
an observer observed (trace cursor, connection failures, filter statistics).

Composed into TailCoProductOutput as the meta field.
"""
from pydantic import BaseModel, Field

from CoTypes.Comonad.Trace.default import TraceComonad


class TailCoProductMeta(BaseModel):
    """TailCoProductMeta [CoProduct] — SSE observer metadata composable into TailCoProductOutput (3 fields)."""
    trace: TraceComonad = Field(
        default_factory=TraceComonad,
        description="Coalgebraic observation cursor — tracks SSE stream position and liveness")
    connection_failures: int = Field(default=0, ge=0, le=10_000,
        description="Number of times connection to the SSE source was lost and retried")
    filter_misses: int = Field(default=0, ge=0, le=10_000_000,
        description="Number of events received but not displayed due to filter_kinds mismatch")
