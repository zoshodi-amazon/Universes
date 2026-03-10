"""CatalogInductive [Inductive] — Structural validation for yfinance screener response (1 field).

Crystalline phase — validates screener API response structure.
count removed: derivable as len(quotes), violates Independence invariant.
"""
from typing import Any
from pydantic import BaseModel, Field

from Types.Inductive.CatalogEntry.default import CatalogEntryInductive


class CatalogInductive(BaseModel):
    """CatalogInductive [Inductive] — Validated screener response."""
    quotes: list[CatalogEntryInductive] = Field(default_factory=list, max_length=1000,
        description="List of validated quotes from screener")

    @classmethod
    def from_response(cls, response: dict[str, Any] | None) -> "CatalogInductive":
        """Validate and convert screener response."""
        if response is None:
            return cls(quotes=[])
        raw_quotes = response.get("quotes", [])
        quotes: list[CatalogEntryInductive] = []
        for q in raw_quotes:
            if isinstance(q, dict) and "symbol" in q:
                quotes.append(CatalogEntryInductive(symbol=q["symbol"]))
        return cls(quotes=quotes)

    def get_tickers(self) -> list[str]:
        """Extract ticker symbols."""
        return [q.symbol for q in self.quotes]
