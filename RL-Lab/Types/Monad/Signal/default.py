"""SignalMonad [Monad] — Threshold-based alert (5 fields).

Plasma phase — effectful alarm observation.
AlarmName and AlarmMessage aliases dissolved — constraints inlined on fields.
"""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Inductive.Severity.default import SeverityInductive


class SignalMonad(BaseModel):
    """SignalMonad [Monad] — Threshold breach alert record."""

    name: Annotated[
        str,
        StringConstraints(pattern=r"^[a-z_][a-z0-9_]*$", min_length=1, max_length=64),
    ] = Field(..., description="Alarm name in snake_case")
    severity: SeverityInductive = Field(
        default=SeverityInductive.warn, description="Alarm severity level"
    )
    message: Annotated[str, StringConstraints(max_length=256)] = Field(
        default="", description="Human-readable alarm message"
    )
    threshold: float = Field(
        default=0.0,
        ge=-1e15,
        le=1e15,
        description="Threshold value that triggered alarm",
    )
    actual: float = Field(
        default=0.0,
        ge=-1e15,
        le=1e15,
        description="Actual value that breached threshold",
    )
