"""SeverityInductive [Inductive] — ADT for alarm severity levels (3 variants).

Crystalline phase — exhaustively checkable sum type replacing Literal["info", "warn", "critical"].
"""

from enum import Enum


class SeverityInductive(str, Enum):
    """SeverityInductive [Inductive] — Alarm severity level."""

    info = "info"
    warn = "warn"
    critical = "critical"
