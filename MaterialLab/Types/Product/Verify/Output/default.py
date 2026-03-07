from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class VerifyProductOutput(BaseModel):
    """[Product] — Verify phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    dimensions_ok: bool = Field(
        default=False,
        description="All dimensions within tolerance",
    )
    tolerances_ok: bool = Field(
        default=False,
        description="All GD&T checks passed",
    )
    printability_ok: bool = Field(
        default=False,
        description="Printability checks passed",
    )
    max_deviation_mm: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Maximum dimensional deviation (sentinel -1.0 = not set)",
    )
    overhang_warnings: int = Field(
        default=0,
        ge=0,
        le=100000,
        description="Number of overhang warnings",
    )
