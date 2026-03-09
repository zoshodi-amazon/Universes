"""CoDiscoveryHom [CoHom] — Discovery phase observation spec (4 fields). All bounded.

Liquid-dual — observation specification parallel to DiscoveryHom.
Specifies what to check when observing a Discovery phase output.
"""

from pydantic import BaseModel, Field


class CoDiscoveryHom(BaseModel):
    """CoDiscoveryHom [CoHom] — What to verify about a discovery run (4 fields)."""

    universe_resolved: bool = Field(
        default=True,
        description="Check that io_universe tickers were resolved to valid assets",
    )
    screener_responded: bool = Field(
        default=True,
        description="Check that the screener API returned a parseable response",
    )
    adx_filter_applied: bool = Field(
        default=True,
        description="Check that ADX filtering was applied with min_adx threshold",
    )
    qualifying_found: bool = Field(
        default=True,
        description="Check that at least one qualifying ticker passed all filters",
    )
