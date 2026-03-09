"""CoAlgoInductive [CoInductive] — Algorithm elimination witness (2 fields). All bounded.

Crystalline-dual — validates that an AlgoIdentity variant maps to an available SB3 class.
"""

from pydantic import BaseModel, Field


class CoAlgoInductive(BaseModel):
    """CoAlgoInductive [CoInductive] — Algorithm availability witness (2 fields)."""

    variant_valid: bool = Field(
        default=False,
        description="Whether the algo string matches a known AlgoIdentity variant",
    )
    sb3_importable: bool = Field(
        default=False,
        description="Whether the corresponding stable-baselines3 class can be imported",
    )
