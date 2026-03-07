"""MetricMonad [Monad] — Counter or gauge measurement (3 fields).

Plasma phase — effectful metric observation.
MetricName alias dissolved — constraint inlined on field.
"""
from typing import Annotated, Literal
from pydantic import BaseModel, Field, StringConstraints


class MetricMonad(BaseModel):
    """MetricMonad [Monad] — Single metric observation point."""
    name: Annotated[str, StringConstraints(pattern=r"^[a-z_][a-z0-9_]*$", min_length=1, max_length=64)] = Field(
        ..., description="Metric name in snake_case")
    value: float = Field(ge=-1e15, le=1e15,
        description="Metric value")
    kind: Literal["counter", "gauge"] = Field(default="gauge",
        description="Metric kind — counter (monotonic) or gauge (point-in-time)")
