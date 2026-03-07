from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class SimulationProductMeta(BaseModel):
    """[Product] — Simulation phase meta, Gas phase."""

    mesh_elements: int = Field(
        default=0,
        ge=0,
        le=100_000_000,
        description="FEA mesh element count",
    )
    solver_time_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Solver wall time (sentinel -1.0 = not set)",
    )
    load_cases_run: int = Field(
        default=0,
        ge=0,
        le=100,
        description="Load cases evaluated",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.simulation),
        description="Observability data — errors, metrics, alarms, timing",
    )
