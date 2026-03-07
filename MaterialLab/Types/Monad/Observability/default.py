from pydantic import BaseModel, Field

from Types.Monad.Error.default import ErrorMonad, PhaseId
from Types.Monad.Metric.default import MetricMonad
from Types.Monad.Alarm.default import AlarmMonad


class ObservabilityMonad(BaseModel):
    """[Monad] — Observability free structure, Plasma phase. Composed into every ProductMeta."""

    errors: list[ErrorMonad] = Field(
        default_factory=list,
        description="Collected errors",
    )
    metrics: list[MetricMonad] = Field(
        default_factory=list,
        description="Collected metrics",
    )
    alarms: list[AlarmMonad] = Field(
        default_factory=list,
        description="Collected alarms",
    )
    phase: PhaseId = Field(
        description="Which phase this observability record belongs to"
    )
    duration_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e9,
        description="Execution duration in seconds (sentinel -1.0 = not set)",
    )
    started_at: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="ISO start timestamp (sentinel '' = not set)",
    )
    completed_at: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="ISO completion timestamp (sentinel '' = not set)",
    )
