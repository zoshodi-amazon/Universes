"""IngestProductOutput [Product] — Ingest phase output (5 fields). Self-contained.

io_start_date and io_data_path removed: both were manual foreign keys into the
ad-hoc Env/ filesystem store. Artifact location and start date are now managed
by StoreMonad (DB row created_at + blob_path). The type records only what the
phase computed, not where it stored things.

io_ticker: naming consistent with IndexIdentity.io_ticker, EvalProductOutput.io_ticker,
and ProjectProductOutput.io_ticker — all output types echo the IO-boundary ticker
symbol as io_ticker.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Product.Ingest.Meta.default import IngestProductMeta
import uuid


class IngestProductOutput(BaseModel):
    """IngestProductOutput [Product] — Result of data ingestion: downloaded OHLCV bars (5 fields)."""
    session_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    io_ticker: Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)] = Field(
        ..., description="Ticker symbol that was ingested — echoes the IO-boundary IndexIdentity.io_ticker")
    interval_min: int = Field(ge=1, le=1440,
        description="Bar interval in minutes used for download")
    n_bars: int = Field(ge=1, le=100_000,
        description="Number of bars after warmup trimming")
    meta: IngestProductMeta = Field(default_factory=IngestProductMeta,
        description="Ingest metadata: observability + audit")
