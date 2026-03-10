"""CoFilterDependent [CoDependent] — Liquidity schema conformance witness (2 fields). All bounded.

Liquid Crystal-dual — validates that FilterDependent percentile bounds are sensible.
"""

from pydantic import BaseModel, Field


class CoFilterDependent(BaseModel):
    """CoFilterDependent [CoDependent] — Liquidity bounds consistency witness (2 fields)."""

    percentiles_in_range: bool = Field(
        default=False,
        description="Whether volume and price percentiles are in [0, 100]",
    )
    spread_positive: bool = Field(
        default=False, description="Whether max_spread_pct is strictly positive"
    )
