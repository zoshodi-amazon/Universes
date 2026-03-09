"""CoFeatureProductOutput [CoProduct] — Feature observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Feature.Meta.default import CoFeatureProductMeta


class CoFeatureProductOutput(BaseModel):
    """CoFeatureProductOutput [CoProduct] — What was observed about a feature run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    features_present: bool = Field(
        default=False, description="Whether feature blob exists on disk"
    )
    column_count_valid: bool = Field(
        default=False,
        description="Whether feature column count matches expected 18 static + 2 dynamic",
    )
    prefix_enforced: bool = Field(
        default=False,
        description="Whether all feature columns start with feature_ prefix",
    )
    meta: CoFeatureProductMeta = Field(
        default_factory=CoFeatureProductMeta,
        description="Observation metadata — trace cursor",
    )
