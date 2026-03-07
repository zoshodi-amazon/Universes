"""TailCoProductOutput [CoProduct] — Tail observer output (5 fields). All bounded.

Gas-dual phase — the dual of a ProductOutput type. Where ProductOutput records
what a phase produced, CoProductOutput records what an observer saw.

extract(TailCoProductOutput) → the sequence of events displayed (via trace cursor).
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid

from CoTypes.CoProduct.Tail.Meta.default import TailCoProductMeta


class TailCoProductOutput(BaseModel):
    """TailCoProductOutput [CoProduct] — Result of SSE event stream observation session (5 fields)."""
    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$")] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex observer instance identifier")
    events_received: int = Field(default=0, ge=0, le=10_000_000,
        description="Total SSE events received from the server, including filtered ones")
    events_displayed: int = Field(default=0, ge=0, le=10_000_000,
        description="Total SSE events that passed filter_kinds and were displayed")
    server_url: Annotated[str, StringConstraints(min_length=1, max_length=256)] = Field(
        default="http://127.0.0.1:4096",
        description="Full URL of the OpenCode SSE endpoint that was observed")
    meta: TailCoProductMeta = Field(
        default_factory=TailCoProductMeta,
        description="Observer metadata — trace cursor, connection failures, filter statistics")
