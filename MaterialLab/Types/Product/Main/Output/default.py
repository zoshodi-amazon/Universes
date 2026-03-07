from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class MainProductOutput(BaseModel):
    """[Product] — Main phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    design_name: str = Field(
        default="",
        min_length=0,
        max_length=128,
        description="Design that was built",
    )
    phases_completed: int = Field(
        default=0,
        ge=0,
        le=7,
        description="Number of phases completed",
    )
    duration_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e9,
        description="Total pipeline duration (sentinel -1.0 = not set)",
    )
    status: str = Field(
        default="pending",
        min_length=1,
        max_length=20,
        description="Pipeline status: pending, running, success, failed",
    )
    deployed: bool = Field(
        default=False,
        description="Whether artifact was deployed to target",
    )
