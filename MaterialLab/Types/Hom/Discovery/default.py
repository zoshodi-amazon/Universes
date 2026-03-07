"""DiscoveryHom [Hom] — Discovery phase input morphism, Liquid phase.

Discovery phase input controlling catalog search parameters: which sources
to query, search filters, manufacturing method, material constraint, and
result limits. No optional fields; sentinels used where absence must be
representable (io_query="" = browse all, target_material="" = any).
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class DiscoveryHom(BaseModel):
    """[Hom] — Discovery phase input morphism, Liquid phase."""

    io_sources: list[str] = Field(
        default=["local"],
        max_length=7,
        description="Catalog sources to search, e.g. ['local', 'thingiverse']. Max 7 entries.",
    )
    io_query: Annotated[str, StringConstraints(min_length=0, max_length=256)] = Field(
        default="",
        description="Search query string; sentinel '' = browse all.",
    )
    target_method: Annotated[str, StringConstraints(min_length=1, max_length=20)] = (
        Field(
            default="fdm",
            description="Manufacturing method filter (references ManufMethodInductive), e.g. 'fdm'.",
        )
    )
    target_material: Annotated[str, StringConstraints(min_length=0, max_length=20)] = (
        Field(
            default="",
            description="Material class filter (references MaterialClassInductive); sentinel '' = any.",
        )
    )
    max_results: int = Field(
        default=20,
        ge=1,
        le=1000,
        description="Maximum number of results to return.",
    )
