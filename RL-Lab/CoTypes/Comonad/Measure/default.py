"""CoMetricComonad [Comonad] — Observation witness for MeasureMonad (4 fields).

Plasma-dual phase — the coalgebraic dual of MeasureMonad.
Where MeasureMonad records counters and gauges during production,
CoMetricComonad witnesses what metrics were observed after the fact.

extract(CoMetricComonad) -> metric_count (current observation summary)
extend(f)(cm)            -> new CoMetricComonad after applying observation function f

Fields satisfy Independence, Completeness, Locality:
- metric_count:  total metrics observed — independent monotonic counter
- has_counters:  whether any counter-type metric was seen — independent boolean axis
- has_gauges:    whether any gauge-type metric was seen — independent boolean axis
- value_range:   observed min-max spread — summary statistic across all metrics
"""

from pydantic import BaseModel, Field


class CoMetricComonad(BaseModel):
    """CoMetricComonad [Comonad] — Observation witness for metric measurements (4 fields)."""

    metric_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Total metrics observed in this observation window",
    )
    has_counters: bool = Field(
        default=False, description="Whether any counter-type metric was observed"
    )
    has_gauges: bool = Field(
        default=False, description="Whether any gauge-type metric was observed"
    )
    value_range: float = Field(
        default=0.0,
        ge=0.0,
        le=1e15,
        description="Spread between min and max observed metric values",
    )
