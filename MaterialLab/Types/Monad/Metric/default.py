from enum import StrEnum

from pydantic import BaseModel, Field


class MetricKind(StrEnum):
    counter = "counter"
    gauge = "gauge"


class MetricMonad(BaseModel):
    """[Monad] — Metric effect type, Plasma phase."""

    name: str = Field(
        min_length=1,
        max_length=64,
        description="Metric name",
    )
    value: float = Field(
        ge=-1e12,
        le=1e12,
        description="Metric value",
    )
    kind: MetricKind = Field(description="Counter (monotonic) or gauge (point-in-time)")
    unit: str = Field(
        default="",
        min_length=0,
        max_length=16,
        description="SI unit label (sentinel '' = dimensionless)",
    )
