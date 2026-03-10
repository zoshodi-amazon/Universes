"""ThresholdDependent [Dependent] — Configurable alarm thresholds with bounded defaults.

Used by phases to evaluate and emit alarms when thresholds are breached.
All thresholds are bounded with sensible defaults.
"""
from pydantic import BaseModel, Field


class ThresholdDependent(BaseModel):
    """ThresholdDependent [Dependent] — Configurable alarm thresholds with bounded defaults (6 fields)."""
    min_qualifying_tickers: int = Field(default=3, ge=1, le=1000,
        description="Warn if fewer tickers pass filters")
    max_phase_duration_s: float = Field(default=300.0, ge=1.0, le=86400.0,
        description="Warn if phase exceeds this duration")
    max_api_failures: int = Field(default=5, ge=0, le=100,
        description="Critical if API failures exceed this count")
    max_error_rate_pct: float = Field(default=10.0, ge=0.0, le=100.0,
        description="Warn if error rate exceeds this percentage")
    notify_on_critical: bool = Field(default=True,
        description="Emit critical alarms to output")
    enabled: bool = Field(default=True,
        description="Enable alarm evaluation")
