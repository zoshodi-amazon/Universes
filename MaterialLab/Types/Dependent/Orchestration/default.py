"""OrchestrationDependent [Dependent] — Pipeline orchestration parameterization, Liquid Crystal phase.

Parameterized pipeline orchestration covering parameter sweeps and
deployment targets. Pipeline composition lives here, NOT in Hom/.
No optional fields; sentinels ("") used where absence must be representable.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class OrchestrationDependent(BaseModel):
    """[Dependent] — Pipeline orchestration parameterization, Liquid Crystal phase."""

    sweep_enabled: bool = Field(
        default=False,
        description="Enable parameter sweep mode.",
    )
    sweep_param: Annotated[str, StringConstraints(min_length=0, max_length=64)] = Field(
        default="",
        description="Parameter to sweep (sentinel '' = disabled).",
    )
    sweep_steps: int = Field(
        default=5,
        ge=1,
        le=100,
        description="Number of sweep steps.",
    )
    deploy_enabled: bool = Field(
        default=False,
        description="Deploy to manufacturing target after pipeline.",
    )
    io_deploy_target: Annotated[
        str, StringConstraints(min_length=0, max_length=128)
    ] = Field(
        default="",
        description="Deployment target URL/path (sentinel '' = not set).",
    )
