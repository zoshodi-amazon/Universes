"""MeasureInductive [Inductive] — ADT for metric measurement kinds (2 variants).

Crystalline phase — exhaustively checkable sum type replacing Literal["counter", "gauge"].
"""

from enum import Enum


class MeasureInductive(str, Enum):
    """MeasureInductive [Inductive] — Metric measurement kind."""

    counter = "counter"
    gauge = "gauge"
