"""CoServeProductOutput [CoProduct] — Serve observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Serve.Meta.default import CoServeProductMeta


class CoServeProductOutput(BaseModel):
    """CoServeProductOutput [CoProduct] — What was observed about a serve run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    audit_present: bool = Field(
        default=False, description="Whether audit JSONL file exists"
    )
    orders_logged: bool = Field(
        default=False, description="Whether trade orders were logged in audit"
    )
    shutdown_clean: bool = Field(
        default=False, description="Whether shutdown reason was recorded"
    )
    meta: CoServeProductMeta = Field(
        default_factory=CoServeProductMeta,
        description="Observation metadata — trace cursor",
    )
