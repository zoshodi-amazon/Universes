"""[Inductive] — Manufacturing method ADT, Crystalline phase."""

from enum import StrEnum

from pydantic import BaseModel, Field


class ManufMethodInductive(StrEnum):
    """Finite variant type for manufacturing methods."""

    fdm = "fdm"
    sla = "sla"
    cnc = "cnc"
    laser = "laser"
    injection = "injection"
