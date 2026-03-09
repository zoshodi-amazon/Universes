"""CoScreenerInductive [CoInductive] — Screener elimination witness (2 fields). All bounded.

Crystalline-dual — validates that a yfinance screener response is parseable.
"""

from pydantic import BaseModel, Field


class CoScreenerInductive(BaseModel):
    """CoScreenerInductive [CoInductive] — Screener response conformance witness (2 fields)."""

    response_parseable: bool = Field(
        default=False,
        description="Whether the screener response can be parsed into ScreenerInductive",
    )
    quotes_non_empty: bool = Field(
        default=False,
        description="Whether at least one quote was returned in the screener response",
    )
