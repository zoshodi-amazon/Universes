from __future__ import annotations

from pydantic import BaseModel, Field


class CoMainHom(BaseModel):
    """[CoHom] — Main observation spec, dual of MainHom."""

    check_all_phases_complete: bool = Field(
        default=True,
        description="Verify all pipeline phases completed",
    )
    check_artifacts_present: bool = Field(
        default=True,
        description="Verify all expected artifacts are present",
    )
    check_type_integrity: bool = Field(
        default=True,
        description="Structural type system validation",
    )
    verbose_provenance: bool = Field(
        default=False,
        description="Detailed provenance output",
    )
