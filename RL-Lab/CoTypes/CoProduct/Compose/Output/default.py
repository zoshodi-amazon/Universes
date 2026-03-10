"""CoComposeProductOutput [CoProduct] — Main observation result (7 fields). All bounded.

Main is the composite phase (QGP). Its observation result includes:
- Pipeline artifact observation booleans (original)
- Type system validation summary (flattened from CoIOValidatePhase)
- Visualization summary (flattened from IOVisualizePhase)
"""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Compose.Meta.default import CoComposeProductMeta


class CoComposeProductOutput(BaseModel):
    """CoComposeProductOutput [CoProduct] — What was observed about a main run (7 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    pipeline_completed: bool = Field(
        default=False, description="Whether main pipeline ran to completion"
    )
    windows_evaluated: bool = Field(
        default=False, description="Whether walk-forward windows were evaluated"
    )
    result_persisted: bool = Field(
        default=False,
        description="Whether ComposeProductOutput was persisted to StoreMonad",
    )
    validate_passed: bool = Field(
        default=False,
        description="Whether type system validation passed (imports, fields, JSON fidelity)",
    )
    visualize_logged: bool = Field(
        default=False,
        description="Whether cross-phase Rerun visualization was logged",
    )
    meta: CoComposeProductMeta = Field(
        default_factory=CoComposeProductMeta,
        description="Observation metadata — trace cursor + validation detail",
    )
