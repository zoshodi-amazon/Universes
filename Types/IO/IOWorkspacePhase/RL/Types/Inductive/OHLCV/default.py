"""OHLCVInductive [Inductive] — Structural validation for OHLCV DataFrames (5 fields).

Crystalline phase — validates yfinance DataFrame has required columns and types.
"""
from pydantic import BaseModel, Field
import pandas as pd


REQUIRED_COLUMNS = {"open", "high", "low", "close", "volume"}


class OHLCVInductive(BaseModel):
    """OHLCVInductive [Inductive] — Validated OHLCV data structure."""
    open: list[float] = Field(..., min_length=1, max_length=10_000_000, description="Opening prices")
    high: list[float] = Field(..., min_length=1, max_length=10_000_000, description="High prices")
    low: list[float] = Field(..., min_length=1, max_length=10_000_000, description="Low prices")
    close: list[float] = Field(..., min_length=1, max_length=10_000_000, description="Closing prices")
    volume: list[float] = Field(..., min_length=1, max_length=10_000_000, description="Volume")

    @classmethod
    def from_dataframe(cls, df: pd.DataFrame | None) -> "OHLCVInductive":
        """Validate and convert DataFrame to OHLCVInductive."""
        if df is None or len(df) == 0:
            raise ValueError("DataFrame is empty or None")
        if isinstance(df.columns, pd.MultiIndex):
            df.columns = df.columns.get_level_values(0)
        df.columns = [c.lower() for c in df.columns]
        missing = REQUIRED_COLUMNS - set(df.columns)
        if missing:
            raise ValueError(f"Missing required columns: {missing}")
        return cls(
            open=df["open"].tolist(),
            high=df["high"].tolist(),
            low=df["low"].tolist(),
            close=df["close"].tolist(),
            volume=df["volume"].tolist(),
        )

    def to_dataframe(self, index: pd.DatetimeIndex | None = None) -> pd.DataFrame:
        """Convert back to DataFrame."""
        data = {"open": self.open, "high": self.high, "low": self.low, "close": self.close, "volume": self.volume}
        return pd.DataFrame(data, index=index)
