"""[Inductive] — CAD file format ADT, Crystalline phase."""

from enum import StrEnum

from pydantic import BaseModel, Field


class CadFormatInductive(StrEnum):
    """Finite variant type for supported CAD file formats."""

    step = "step"
    stl = "stl"
    threemf = "threemf"
    iges = "iges"
    obj = "obj"
