from __future__ import annotations

from pydantic import BaseModel, Field


class CoMainProductOutput(BaseModel):
    """[CoProduct] — Main observation output, dual of MainProductOutput."""

    observed: bool = Field(
        default=False,
        description="Whether observation was performed",
    )
    passed: bool = Field(
        default=False,
        description="Whether all checks passed",
    )
    findings_count: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Number of findings/issues",
    )
    summary: str = Field(
        default="",
        min_length=0,
        max_length=1024,
        description="Human-readable observation summary",
    )
