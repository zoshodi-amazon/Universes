"""CoThresholdDependent [CoDependent] — Alarm schema conformance witness (2 fields). All bounded.

Liquid Crystal-dual — validates that ThresholdDependent thresholds are internally consistent.
"""

from pydantic import BaseModel, Field


class CoThresholdDependent(BaseModel):
    """CoThresholdDependent [CoDependent] — Alarm threshold consistency witness (2 fields)."""

    thresholds_positive: bool = Field(
        default=False, description="Whether all alarm thresholds are strictly positive"
    )
    enabled_consistent: bool = Field(
        default=False,
        description="Whether enabled=False implies no alarms will fire (consistent state)",
    )
