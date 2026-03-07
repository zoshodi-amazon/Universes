from __future__ import annotations

from pydantic import BaseModel, Field


class CoSimulationHom(BaseModel):
    """[CoHom] — Simulation observation spec, dual of SimulationHom."""

    check_convergence: bool = Field(
        default=True,
        description="Verify simulation solver converged",
    )
    check_safety_factor: bool = Field(
        default=True,
        description="Verify safety factor meets threshold",
    )
    check_max_stress: bool = Field(
        default=True,
        description="Verify maximum stress is within limits",
    )
    render_stress_field: bool = Field(
        default=False,
        description="Enable scalar field rendering",
    )
