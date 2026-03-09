"""ScreenerInductive [Inductive] — Structural validation for yfinance screener response (1 field).

Crystalline phase — validates screener API response structure.
count removed: derivable as len(quotes), violates Independence invariant.
"""
from typing import Any
from pydantic import BaseModel, Field

from Types.Inductive.ScreenerQuote.default import ScreenerQuoteInductive


class ScreenerInductive(BaseModel):
    """ScreenerInductive [Inductive] — Validated screener response."""
    quotes: list[ScreenerQuoteInductive] = Field(default_factory=list, max_length=1000,
        description="List of validated quotes from screener")

    @classmethod
    def from_response(cls, response: dict[str, Any] | None) -> "ScreenerInductive":
        """Validate and convert screener response."""
        if response is None:
            return cls(quotes=[])
        raw_quotes = response.get("quotes", [])
        quotes: list[ScreenerQuoteInductive] = []
        for q in raw_quotes:
            if isinstance(q, dict) and "symbol" in q:
                quotes.append(ScreenerQuoteInductive(symbol=q["symbol"]))
        return cls(quotes=quotes)

    def get_tickers(self) -> list[str]:
        """Extract ticker symbols."""
        return [q.symbol for q in self.quotes]
