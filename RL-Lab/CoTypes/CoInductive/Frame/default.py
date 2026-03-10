"""CoFrameInductive [CoInductive] — OHLCV schema elimination witness (4 fields). All bounded.

Crystalline-dual — validates that a DataFrame conforms to the FrameInductive schema.
"""

from pydantic import BaseModel, Field


class CoFrameInductive(BaseModel):
    """CoFrameInductive [CoInductive] — OHLCV DataFrame conformance witness (4 fields)."""

    columns_present: bool = Field(
        default=False,
        description="Whether all 5 required columns (open, high, low, close, volume) are present",
    )
    dtypes_numeric: bool = Field(
        default=False, description="Whether all OHLCV columns have numeric dtypes"
    )
    no_nulls: bool = Field(
        default=False,
        description="Whether the DataFrame contains zero null values in OHLCV columns",
    )
    index_sorted: bool = Field(
        default=False,
        description="Whether the DatetimeIndex is monotonically increasing",
    )
