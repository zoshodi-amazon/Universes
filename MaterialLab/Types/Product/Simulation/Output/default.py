from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class SimulationProductOutput(BaseModel):
    """[Product] — Simulation phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    max_stress_mpa: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e9,
        description="Peak von Mises stress (sentinel -1.0 = not set)",
    )
    max_displacement_mm: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Peak displacement (sentinel -1.0 = not set)",
    )
    safety_factor_min: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1000.0,
        description="Minimum safety factor (sentinel -1.0 = not set)",
    )
    converged: bool = Field(
        default=False,
        description="Solver converged",
    )
    iterations_used: int = Field(
        default=0,
        ge=0,
        le=100000,
        description="Solver iterations taken",
    )
