from __future__ import annotations

from enum import StrEnum

from pydantic import BaseModel, Field


class CoPhaseId(StrEnum):
    """Enumeration of observable pipeline phases."""

    discovery = "discovery"
    ingest = "ingest"
    geometry = "geometry"
    simulation = "simulation"
    fabrication = "fabrication"
    verify = "verify"
    main = "main"


class TraceComonad(BaseModel):
    """[Comonad] — Observation trace cursor. Dual of Monad/. Extract current + extend history."""

    observer_id: str = Field(
        min_length=1,
        max_length=64,
        description="Identity of observer instance",
    )
    phase: CoPhaseId = Field(
        description="Which phase is being observed",
    )
    cursor: str = Field(
        default="",
        min_length=0,
        max_length=256,
        description="Current position in observation space",
    )
    events_seen: int = Field(
        default=0,
        ge=0,
        le=1_000_000,
        description="Monotonically increasing counter",
    )
    last_seen_at: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="ISO timestamp of last observation",
    )
