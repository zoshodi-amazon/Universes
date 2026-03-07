from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class DiscoveryProductOutput(BaseModel):
    """[Product] — Discovery phase output, Gas phase."""

    run_id: Annotated[
        str,
        StringConstraints(min_length=8, max_length=8),
    ] = Field(description="Pipeline run identifier")
    results_count: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Number of results found",
    )
    top_design_name: str = Field(
        default="",
        min_length=0,
        max_length=128,
        description="Best matching design name",
    )
    top_design_source: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="Source of best match",
    )
    catalog_sources_searched: int = Field(
        default=0,
        ge=0,
        le=100,
        description="Number of catalogs searched",
    )
