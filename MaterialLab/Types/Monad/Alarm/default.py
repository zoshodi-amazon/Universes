from pydantic import BaseModel, Field

from Types.Monad.Error.default import Severity


class AlarmMonad(BaseModel):
    """[Monad] — Alarm effect type, Plasma phase."""

    name: str = Field(
        min_length=1,
        max_length=64,
        description="Alarm name",
    )
    threshold: float = Field(
        ge=-1e12,
        le=1e12,
        description="Threshold value",
    )
    actual: float = Field(
        ge=-1e12,
        le=1e12,
        description="Actual observed value",
    )
    triggered: bool = Field(description="Whether the alarm fired")
    severity: Severity = Field(description="Alarm severity level")
