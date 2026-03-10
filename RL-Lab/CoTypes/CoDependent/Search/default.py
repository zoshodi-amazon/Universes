"""CoSearchDependent [CoDependent] — Optimize schema conformance witness (3 fields). All bounded.

Liquid Crystal-dual — validates that SearchDependent search space ranges are consistent.
"""

from pydantic import BaseModel, Field


class CoSearchDependent(BaseModel):
    """CoSearchDependent [CoDependent] — Optimize search space consistency witness (3 fields)."""

    lr_range_valid: bool = Field(
        default=False, description="Whether search_space_lr_min < search_space_lr_max"
    )
    timesteps_range_valid: bool = Field(
        default=False,
        description="Whether search_space_timesteps_min < search_space_timesteps_max",
    )
    n_trials_positive: bool = Field(default=False, description="Whether n_trials >= 1")
