"""MaterialIdentity [Identity] — terminal object, BEC phase.

Terminal object for a single material in the MaterialLab type universe.
Captures the material's name and core physical properties with strict
numeric bounds. No optional fields; sentinels used where absence must
be representable.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class MaterialIdentity(BaseModel):
    """Terminal identity for a single material."""

    io_name: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        description="Material display name, e.g. 'PLA Generic'."
    )
    density_kg_m3: float = Field(
        ge=100.0,
        le=25000.0,
        description="Material density in kg/m^3.",
    )
    yield_strength_mpa: float = Field(
        ge=0.1,
        le=5000.0,
        description="Yield strength in MPa.",
    )
    thermal_max_c: float = Field(
        ge=-273.15,
        le=3500.0,
        description="Maximum service temperature in Celsius.",
    )
    elastic_modulus_gpa: float = Field(
        ge=0.001,
        le=1200.0,
        description="Young's modulus (elastic modulus) in GPa.",
    )
    cost_per_kg_usd: float = Field(
        ge=0.01,
        le=100000.0,
        description="Cost per kilogram in USD.",
    )
