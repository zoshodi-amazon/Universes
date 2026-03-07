from __future__ import annotations

from pydantic import BaseModel, Field


class CoMainProductMeta(BaseModel):
    """[CoProduct] — Main observation meta, dual of MainProductMeta."""

    observer_duration_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e9,
        description="Observer execution time in seconds",
    )
    checks_run: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Number of checks executed",
    )
    checks_passed: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Number of checks that passed",
    )
