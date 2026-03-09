"""CoServeHom [CoHom] — Serve phase observation spec (5 fields). All bounded.

Liquid-dual — observation specification parallel to ServeHom.
"""

from pydantic import BaseModel, Field


class CoServeHom(BaseModel):
    """CoServeHom [CoHom] — What to verify about a serve run (5 fields)."""

    model_loaded: bool = Field(
        default=True, description="Check that model was loaded and not stale"
    )
    data_fresh: bool = Field(
        default=True, description="Check that live data passed the freshness gate"
    )
    features_valid: bool = Field(
        default=True,
        description="Check that feature columns matched model expectations",
    )
    audit_logged: bool = Field(
        default=True,
        description="Check that audit JSONL was written for each trading step",
    )
    shutdown_clean: bool = Field(
        default=True,
        description="Check that shutdown flattened positions and logged final state",
    )
