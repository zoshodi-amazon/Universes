"""CoDiscoveryProductOutput [CoProduct] — Discovery observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Discovery.Meta.default import CoDiscoveryProductMeta


class CoDiscoveryProductOutput(BaseModel):
    """CoDiscoveryProductOutput [CoProduct] — What was observed about a discovery run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    universe_resolved: bool = Field(
        default=False, description="Whether universe tickers resolved to valid assets"
    )
    screener_responded: bool = Field(
        default=False, description="Whether screener API returned a parseable response"
    )
    qualifying_found: bool = Field(
        default=False,
        description="Whether qualifying tickers were found after filtering",
    )
    meta: CoDiscoveryProductMeta = Field(
        default_factory=CoDiscoveryProductMeta,
        description="Observation metadata — trace cursor",
    )
