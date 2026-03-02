"""DiscoveryOutput [Gas] — Discovery phase output (<=7 params). All bounded."""
from pydantic import BaseModel, Field
from Types.UnitTypes.FieldUnit.default import RunId, Ticker, ISODate, FilePath
import uuid

class DiscoveryOutput(BaseModel):
    """DiscoveryOutput [Gas] — Result of asset discovery: which tickers passed ADX trend filtering."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    universe_size: int = Field(ge=1, le=10_000, description="Total number of tickers scanned before filtering")
    qualifying_tickers: list[Ticker] = Field(max_length=10_000, description="Tickers that passed ADX threshold, sorted by ADX descending")
    min_adx_used: float = Field(ge=0.0, le=100.0, description="ADX (Average Directional Index) threshold used for filtering")
    io_scan_date: ISODate = Field(..., description="ISO date when the discovery scan was performed")
    n_qualifying: int = Field(ge=0, le=10_000, description="Count of tickers that passed the ADX filter")
    io_data_path: FilePath = Field(..., description="File path to the persisted discovery output JSON")
