"""MetricKind [Inductive] — ADT for metric measurement kinds (2 variants).

Crystalline phase — exhaustively checkable sum type replacing Literal["counter", "gauge"].
"""

from enum import Enum


class MetricKind(str, Enum):
    """MetricKind [Inductive] — Metric measurement kind."""

    counter = "counter"
    gauge = "gauge"
