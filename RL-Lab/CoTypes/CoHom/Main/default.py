"""CoMainHom [CoHom] — Main phase observation spec (7 fields). All bounded.

Liquid-dual — observation specification parallel to MainHom.
Main is the composite phase (QGP). Its observer absorbs cross-cutting observations:
- Pipeline artifact probing (original)
- Type system structural validation (flattened from CoIOValidatePhase)
- Cross-phase visualization (flattened from IOVisualizePhase)
"""

from pydantic import BaseModel, Field


class CoMainHom(BaseModel):
    """CoMainHom [CoHom] — What to verify about a main pipeline run (7 fields)."""

    all_phases_completed: bool = Field(
        default=True,
        description="Check that discovery through eval all completed without fatal error",
    )
    windows_evaluated: bool = Field(
        default=True, description="Check that walk-forward windows were evaluated"
    )
    result_persisted: bool = Field(
        default=True,
        description="Check that final MainProductOutput was persisted to StoreMonad",
    )
    validate_imports: bool = Field(
        default=True,
        description="Check that all type modules import without error",
    )
    validate_fields: bool = Field(
        default=True,
        description="Check that all types have <=7 fields with descriptions and bounds",
    )
    validate_json: bool = Field(
        default=True,
        description="Check default.json fidelity — keys match Settings schema",
    )
    visualize: bool = Field(
        default=False,
        description="Enable cross-phase Rerun visualization of all StoreMonad artifacts",
    )
