"""IngestOutput [Gas] — Ingest phase output (<=7 params). Self-contained."""
from pydantic import BaseModel, Field, constr
import uuid

RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
Ticker = constr(pattern=r"^[A-Z0-9\-./]{1,16}$", min_length=1, max_length=16)
ISODate = constr(pattern=r"^\d{4}-\d{2}-\d{2}", min_length=10, max_length=32)
FilePath = constr(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./]+$")

class IngestOutput(BaseModel):
    """IngestOutput [Gas] — Result of data ingestion: downloaded OHLCV bars with date range."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    io_ticker: Ticker = Field(..., description="Ticker symbol that was ingested")
    interval_min: int = Field(ge=1, le=1440, description="Bar interval in minutes used for download")
    n_bars: int = Field(ge=1, le=100_000, description="Number of bars after warmup trimming")
    io_start_date: ISODate = Field(..., description="ISO date of the first bar in the ingested series")
    io_end_date: ISODate = Field(..., description="ISO date of the last bar in the ingested series")
    io_data_path: FilePath = Field(..., description="File path to the persisted OHLCV pickle")
