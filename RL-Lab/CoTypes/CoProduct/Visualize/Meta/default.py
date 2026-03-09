"""VisualizeCoProductMeta [CoProduct] — Rerun observer metadata (4 fields). All bounded.

Gas-dual phase — the dual of a ProductMeta type. Where ProductMeta records
what a phase produced (errors, timing), CoProductMeta records what an observer
observed (trace cursor, which artifacts were found, what was logged).

Composed into VisualizeCoProductOutput as the meta field.
"""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from CoTypes.Comonad.Trace.default import TraceComonad


class VisualizeCoProductMeta(BaseModel):
    """VisualizeCoProductMeta [CoProduct] — Rerun observer metadata (4 fields)."""

    trace: TraceComonad = Field(
        default_factory=TraceComonad,
        description="Coalgebraic observation cursor — tracks artifact scan position",
    )
    run_ids_found: list[
        Annotated[str, StringConstraints(min_length=1, max_length=32)]
    ] = Field(
        default_factory=list,
        max_length=10_000,
        description="Distinct run_ids found in scanned ProductOutput JSON files",
    )
    phases_found: list[
        Annotated[str, StringConstraints(min_length=1, max_length=32)]
    ] = Field(
        default_factory=list,
        max_length=20,
        description="Phase names (discovery, ingest, ...) for which artifacts were found and logged",
    )
    feature_columns_logged: int = Field(
        default=0,
        ge=0,
        le=10_000,
        description="Number of feature DataFrame columns logged to Rerun — 0 if include_features=False",
    )
