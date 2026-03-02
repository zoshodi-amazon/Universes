"""IngestInput [Liquid] — Ingest phase config (3 params). All bounded.

io_ticker and interval_min now on AssetUnit.
"""
from pydantic import BaseModel, Field, constr
from Types.UnitTypes.FieldUnit.default import DirPath


Period = constr(pattern=r"^\d{1,4}d$", min_length=2, max_length=5)


class IngestInput(BaseModel):
    """IngestInput [Liquid] — Config for downloading and caching raw OHLCV price data."""
    period: Period = Field(default="60d", description="Lookback period for data fetch, e.g. 60d = 60 calendar days")
    warmup_bars: int = Field(default=28, ge=0, le=500, description="Bars discarded at start for indicator warm-up period")
    cache_dir: DirPath = Field(default="Env/Inputs/cache", description="Directory for caching downloaded price data")
