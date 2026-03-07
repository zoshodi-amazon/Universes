from __future__ import annotations

from pydantic import BaseModel, Field


class CoDiscoveryHom(BaseModel):
    """[CoHom] — Discovery observation spec, dual of DiscoveryHom."""

    check_catalog_reachable: bool = Field(
        default=True,
        description="Verify catalog sources are reachable",
    )
    check_results_non_empty: bool = Field(
        default=True,
        description="Verify search returned results",
    )
    check_material_available: bool = Field(
        default=True,
        description="Verify target material exists in results",
    )
