"""[Inductive] — Material class ADT, Crystalline phase."""

from enum import StrEnum

from pydantic import BaseModel, Field


class MaterialClassInductive(StrEnum):
    """Finite variant type for material classifications."""

    pla = "pla"
    abs = "abs"
    petg = "petg"
    nylon = "nylon"
    resin = "resin"
    metal = "metal"
    wood = "wood"
