"""MainHom [Hom] — Main phase input morphism, Liquid phase. Pipeline entrypoint.

Main phase input controlling pipeline orchestration: design name to build,
phase-skip flags, and dry-run mode. No optional fields; all fields carry
concrete defaults or are required.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class MainHom(BaseModel):
    """[Hom] — Main phase input morphism, Liquid phase. Pipeline entrypoint."""

    io_design: Annotated[str, StringConstraints(min_length=1, max_length=128)] = Field(
        description="Design name to build (references DesignIdentity.io_name).",
    )
    skip_simulation: bool = Field(
        default=False,
        description="Skip the simulation phase entirely.",
    )
    skip_verify: bool = Field(
        default=False,
        description="Skip the verify phase entirely.",
    )
    dry_run: bool = Field(
        default=False,
        description="Run the pipeline without writing any artifacts to disk.",
    )
