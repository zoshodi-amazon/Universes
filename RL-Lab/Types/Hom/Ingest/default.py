"""IngestHom [Hom] — Ingest phase config (2 fields). All bounded.

io_ticker and interval_min live on IndexIdentity.
cache_dir lives on SessionIdentity (environment-level path fixpoint).

Fields satisfy Independence, Completeness, Locality:
- period:       how far back to fetch OHLCV bars for training — distinct from
                DiscoveryHom.trend_lookback (discovery scan window)
- warmup_frames:  bars discarded for indicator warm-up — independent of period
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class IngestHom(BaseModel):
    """IngestHom [Hom] — Config for downloading and caching raw OHLCV price data."""
    period: Annotated[str, StringConstraints(pattern=r"^\d{1,4}d$", min_length=2, max_length=5)] = Field(
        default="60d",
        description="Lookback period for OHLCV training data fetch — e.g. 60d = 60 calendar days")
    warmup_frames: int = Field(default=28, ge=0, le=500,
        description="Bars discarded at start for indicator warm-up period")
