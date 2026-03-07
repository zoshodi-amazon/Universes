"""SimulationHom [Hom] — Simulation phase input morphism, Liquid phase.

Simulation phase input controlling FEA setup: load case selection, applied
force, boundary condition type, ambient temperature, and gravity toggle.
No optional fields; all fields carry concrete defaults. All units SI.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class SimulationHom(BaseModel):
    """[Hom] — Simulation phase input morphism, Liquid phase."""

    load_case: Annotated[str, StringConstraints(min_length=1, max_length=20)] = Field(
        default="static",
        description="Simulation load case (references LoadCaseInductive), e.g. 'static'.",
    )
    force_n: float = Field(
        default=100.0,
        ge=0.0,
        le=1e9,
        description="Applied force in Newtons.",
    )
    constraint_type: Annotated[str, StringConstraints(min_length=1, max_length=32)] = (
        Field(
            default="fixed_base",
            description="Boundary condition type, e.g. 'fixed_base', 'pinned', 'roller'.",
        )
    )
    temperature_c: float = Field(
        default=25.0,
        ge=-273.15,
        le=3500.0,
        description="Ambient temperature in degrees Celsius.",
    )
    include_gravity: bool = Field(
        default=True,
        description="Include gravitational load in the simulation.",
    )
