"""MaterialSpecDependent [Dependent] — Material spec parameterization, Liquid Crystal phase.

Parameterized material property sheet covering mechanical strength, thermal
limits, deformation, and shrinkage. No optional fields; sentinels used where
absence must be representable.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class MaterialSpecDependent(BaseModel):
    """[Dependent] — Material spec parameterization, Liquid Crystal phase."""

    tensile_strength_mpa: float = Field(
        default=50.0,
        ge=0.1,
        le=5000.0,
        description="Ultimate tensile strength in MPa.",
    )
    thermal_max_c: float = Field(
        default=60.0,
        ge=-40.0,
        le=3500.0,
        description="Max continuous use temperature in Celsius.",
    )
    elongation_pct: float = Field(
        default=5.0,
        ge=0.0,
        le=1000.0,
        description="Elongation at break as a percentage.",
    )
    elastic_modulus_gpa: float = Field(
        default=2.5,
        ge=0.001,
        le=1200.0,
        description="Young's modulus (elastic modulus) in GPa.",
    )
    thermal_conductivity_w_mk: float = Field(
        default=0.2,
        ge=0.01,
        le=500.0,
        description="Thermal conductivity in W/(m·K).",
    )
    shrinkage_pct: float = Field(
        default=0.5,
        ge=0.0,
        le=10.0,
        description="Expected shrinkage percentage.",
    )
