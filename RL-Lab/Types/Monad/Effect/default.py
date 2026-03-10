"""EffectMonad [Monad] — Free observability structure composable into any phase (7 fields).

Plasma phase — effectful composition of errors, metrics, and alarms.
Composed into {Phase}ProductMeta types.
ISOTimestamp alias dissolved — constraint inlined on field.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Monad.Error.default import ErrorMonad, PhaseId
from Types.Monad.Measure.default import MeasureMonad
from Types.Monad.Signal.default import SignalMonad


class EffectMonad(BaseModel):
    """EffectMonad [Monad] — Free observability structure composable into any phase (7 fields)."""
    errors: list[ErrorMonad] = Field(default_factory=list, max_length=100,
        description="Typed error collection from phase execution")
    metrics: list[MeasureMonad] = Field(default_factory=list, max_length=50,
        description="Phase metrics — counters and gauges")
    alarms: list[SignalMonad] = Field(default_factory=list, max_length=20,
        description="Triggered alarms based on threshold breaches")
    phase: PhaseId = Field(...,
        description="Phase that produced this observability data")
    duration_s: float = Field(default=0.0, ge=0.0, le=86400.0,
        description="Phase execution duration in seconds")
    started_at: Annotated[str, StringConstraints(max_length=32)] = Field(default="",
        description="ISO timestamp when phase started")
    completed_at: Annotated[str, StringConstraints(max_length=32)] = Field(default="",
        description="ISO timestamp when phase completed")
