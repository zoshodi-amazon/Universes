"""CatalogEntryInductive [Inductive] — Single validated screener quote (1 field).

Crystalline phase — validates a single quote from yfinance screener.
ScreenerSymbol alias dissolved — constraint inlined on field.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class CatalogEntryInductive(BaseModel):
    """CatalogEntryInductive [Inductive] — Single validated screener quote."""
    symbol: Annotated[str, StringConstraints(min_length=1, max_length=20)] = Field(
        ..., description="Ticker symbol from screener")
