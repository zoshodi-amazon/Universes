"""[Inductive] — Simulation load case ADT, Crystalline phase."""

from enum import StrEnum

from pydantic import BaseModel, Field


class LoadCaseInductive(StrEnum):
    """Finite variant type for simulation load cases."""

    static = "static"
    dynamic = "dynamic"
    thermal = "thermal"
    impact = "impact"
