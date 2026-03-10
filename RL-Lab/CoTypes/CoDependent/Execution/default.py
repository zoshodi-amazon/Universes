"""CoEnvDependent [CoDependent] — Env schema conformance witness (3 fields). All bounded.

Liquid Crystal-dual — validates that EnvDependent fields are internally consistent.
"""

from pydantic import BaseModel, Field


class CoEnvDependent(BaseModel):
    """CoEnvDependent [CoDependent] — Env configuration consistency witness (3 fields)."""

    broker_mode_valid: bool = Field(
        default=False,
        description="Whether broker_mode is a recognized BrokerMode variant",
    )
    positions_valid: bool = Field(
        default=False,
        description="Whether positions list contains valid ratio values in [-1, 1]",
    )
    fees_non_negative: bool = Field(
        default=False, description="Whether fees_pct and borrow_rate_pct are >= 0"
    )
