from enum import StrEnum

from pydantic import BaseModel, Field


class Severity(StrEnum):
    info = "info"
    warning = "warning"
    error = "error"
    critical = "critical"


class PhaseId(StrEnum):
    discovery = "discovery"
    ingest = "ingest"
    geometry = "geometry"
    simulation = "simulation"
    fabrication = "fabrication"
    verify = "verify"
    main = "main"


class ErrorMonad(BaseModel):
    """[Monad] — Error effect type, Plasma phase."""

    phase: PhaseId = Field(description="Which phase produced this error")
    severity: Severity = Field(description="Error severity level")
    message: str = Field(
        min_length=1,
        max_length=1024,
        description="Human-readable error message",
    )
    timestamp: str = Field(
        min_length=1,
        max_length=32,
        description="ISO timestamp",
    )
