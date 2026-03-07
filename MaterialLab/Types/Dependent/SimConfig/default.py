"""SimConfigDependent [Dependent] — Simulation config parameterization, Liquid Crystal phase.

Parameterized simulation configuration covering mesh resolution, solver
parameters, convergence criteria, and load options. No optional fields;
sentinels used where absence must be representable.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class SimConfigDependent(BaseModel):
    """[Dependent] — Simulation config parameterization, Liquid Crystal phase."""

    mesh_density: int = Field(
        default=5,
        ge=1,
        le=10,
        description="Mesh density level (1=coarse, 10=fine).",
    )
    solver_max_iter: int = Field(
        default=1000,
        ge=10,
        le=100000,
        description="Max solver iterations.",
    )
    convergence_tol: float = Field(
        default=1e-6,
        ge=1e-12,
        le=1e-1,
        description="Convergence tolerance.",
    )
    safety_factor: float = Field(
        default=2.0,
        ge=1.0,
        le=10.0,
        description="Safety factor for stress analysis.",
    )
    gravity_enabled: bool = Field(
        default=True,
        description="Include gravitational load.",
    )
