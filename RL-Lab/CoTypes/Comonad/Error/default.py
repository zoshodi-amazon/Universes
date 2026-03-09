"""CoErrorComonad [Comonad] — Observation witness for ErrorMonad (4 fields).

Plasma-dual phase — the coalgebraic dual of ErrorMonad.
Where ErrorMonad records typed errors during production,
CoErrorComonad witnesses what errors were observed after the fact.

extract(CoErrorComonad) -> error_count (current observation summary)
extend(f)(ce)           -> new CoErrorComonad after applying observation function f

Fields satisfy Independence, Completeness, Locality:
- error_count:      total errors observed — independent monotonic counter
- has_fatal:        whether any fatal-severity error was seen — independent boolean axis
- worst_severity:   highest severity level observed — derived from error scan
- last_message:     most recent error message — temporal cursor into error stream
"""

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints

from Types.Monad.Error.default import Severity


class CoErrorComonad(BaseModel):
    """CoErrorComonad [Comonad] — Observation witness for typed errors (4 fields)."""

    error_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Total errors observed in this observation window",
    )
    has_fatal: bool = Field(
        default=False, description="Whether any fatal-severity error was observed"
    )
    worst_severity: Severity = Field(
        default=Severity.warn,
        description="Highest severity level observed across all errors",
    )
    last_message: Annotated[str, StringConstraints(max_length=1024)] = Field(
        default="",
        description="Most recent error message — temporal cursor into error stream",
    )
