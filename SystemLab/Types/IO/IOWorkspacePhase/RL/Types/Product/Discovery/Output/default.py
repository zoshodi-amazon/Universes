"""DiscoveryProductOutput [Product] — Discovery phase output (5 fields). All bounded.

io_scan_date and io_data_path removed: both were manual foreign keys into the
ad-hoc Env/ filesystem store. Artifact location and scan timestamp are now
managed by StoreMonad (DB row created_at + blob_path). The type records only
what the phase computed, not where it stored things.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid

from Types.Product.Discovery.Meta.default import DiscoveryProductMeta


class DiscoveryProductOutput(BaseModel):
    """DiscoveryProductOutput [Product] — Result of asset discovery: which tickers passed filtering (5 fields)."""
    run_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    universe_size: int = Field(default=0, ge=0, le=100_000,
        description="Total number of tickers scanned before filtering")
    qualifying_tickers: list[Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)]] = Field(
        default_factory=list, max_length=10_000,
        description="Tickers that passed all filters, sorted by ADX descending")
    min_adx_used: float = Field(default=20.0, ge=0.0, le=100.0,
        description="ADX threshold used for filtering — echoed from DiscoveryHom.min_adx for audit")
    meta: DiscoveryProductMeta = Field(default_factory=DiscoveryProductMeta,
        description="Phase-fixed observability + audit data")
