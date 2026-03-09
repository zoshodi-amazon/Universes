"""CoRiskDependent [CoDependent] — Risk schema conformance witness (2 fields). All bounded.

Liquid Crystal-dual — validates that RiskDependent thresholds are consistent.
"""

from pydantic import BaseModel, Field


class CoRiskDependent(BaseModel):
    """CoRiskDependent [CoDependent] — Risk threshold consistency witness (2 fields)."""

    stop_loss_negative: bool = Field(
        default=False,
        description="Whether stop_loss_pct is negative (a loss threshold must be < 0)",
    )
    profit_positive: bool = Field(
        default=False,
        description="Whether profit_threshold_pct is positive (a profit threshold must be > 0)",
    )
