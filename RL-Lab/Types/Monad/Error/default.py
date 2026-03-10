"""ErrorMonad [Monad] — Structured typed error (4 fields).

Plasma phase — effectful error composition. All bounded.
ErrorMessage alias dissolved — constraint inlined on field.
"""

from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class Severity(str, Enum):
    """Error severity level — warn is recoverable, error is phase-failing, fatal is pipeline-halting."""

    warn = "warn"
    error = "error"
    fatal = "fatal"


class PhaseId(str, Enum):
    """Pipeline phase identifier — which stage produced the error."""

    discovery = "discovery"
    ingest = "ingest"
    transform = "transform"
    solve = "solve"
    eval = "eval"
    project = "project"
    compose = "compose"
    search = "search"


class ErrorMonad(BaseModel):
    """ErrorMonad [Monad] — Structured error record attached to phase results."""

    phase: PhaseId = Field(..., description="Pipeline phase that produced this error")
    message: Annotated[str, StringConstraints(min_length=1, max_length=1024)] = Field(
        default="unknown", description="Human-readable error description"
    )
    window_index: int = Field(
        default=-1,
        ge=-1,
        le=10_000,
        description="Walk-forward window index where error occurred, -1 if not windowed",
    )
    severity: Severity = Field(
        default=Severity.error, description="Error severity — warn, error, or fatal"
    )
