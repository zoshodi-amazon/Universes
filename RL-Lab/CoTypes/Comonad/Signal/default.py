"""CoAlarmComonad [Comonad] — Observation witness for SignalMonad (4 fields).

Plasma-dual phase — the coalgebraic dual of SignalMonad.
Where SignalMonad records threshold-based alerts during production,
CoAlarmComonad witnesses what alarms were observed after the fact.

extract(CoAlarmComonad) -> alarm_count (current observation summary)
extend(f)(ca)           -> new CoAlarmComonad after applying observation function f

Fields satisfy Independence, Completeness, Locality:
- alarm_count:     total alarms observed — independent monotonic counter
- has_critical:    whether any critical-severity alarm was seen — independent boolean axis
- worst_severity:  highest alarm severity observed — derived from alarm scan
- last_name:       most recently triggered alarm name — temporal cursor into alarm stream
"""

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints

from Types.Inductive.SeverityInductive.default import SeverityInductive


class CoAlarmComonad(BaseModel):
    """CoAlarmComonad [Comonad] — Observation witness for threshold-based alerts (4 fields)."""

    alarm_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Total alarms observed in this observation window",
    )
    has_critical: bool = Field(
        default=False, description="Whether any critical-severity alarm was observed"
    )
    worst_severity: SeverityInductive = Field(
        default=SeverityInductive.info,
        description="Highest alarm severity level observed across all alarms",
    )
    last_name: Annotated[str, StringConstraints(max_length=64)] = Field(
        default="",
        description="Name of most recently triggered alarm — temporal cursor into alarm stream",
    )
