"""DiscoveryOutput [Gas] — Discovery phase output (<=7 params). All bounded."""
from pydantic import BaseModel, Field, constr
import uuid

RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
Ticker = constr(pattern=r"^[A-Z0-9\-./]{1,16}$", min_length=1, max_length=16)
ISODate = constr(pattern=r"^\d{4}-\d{2}-\d{2}", min_length=10, max_length=32)
FilePath = constr(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./]+$")

class DiscoveryOutput(BaseModel):
    """DiscoveryOutput [Gas] — Result of asset discovery: which tickers passed ADX trend filtering."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    universe_size: int = Field(ge=1, le=10_000, description="Total number of tickers scanned before filtering")
    qualifying_tickers: list[Ticker] = Field(max_length=10_000, description="Tickers that passed ADX threshold, sorted by ADX descending")
    min_adx_used: float = Field(ge=0.0, le=100.0, description="ADX (Average Directional Index) threshold used for filtering")
    io_scan_date: ISODate = Field(..., description="ISO date when the discovery scan was performed")
    n_qualifying: int = Field(ge=0, le=10_000, description="Count of tickers that passed the ADX filter")
    io_data_path: FilePath = Field(..., description="File path to the persisted discovery output JSON")
