"""CoCatalogEntryInductive [CoInductive] — ScreenerQuote elimination witness (2 fields). All bounded.

Crystalline-dual — validates that a screener quote dict has required fields.
"""

from pydantic import BaseModel, Field


class CoCatalogEntryInductive(BaseModel):
    """CoCatalogEntryInductive [CoInductive] — ScreenerQuote field presence witness (2 fields)."""

    symbol_present: bool = Field(
        default=False,
        description="Whether the 'symbol' key exists and is non-empty in the quote dict",
    )
    fields_complete: bool = Field(
        default=False,
        description="Whether all expected fields are present in the quote dict",
    )
