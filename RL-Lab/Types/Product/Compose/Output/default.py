"""ComposeProductOutput [Product] — Full pipeline output (7 params). All bounded.

Returns in percentage. Composes EvalProductOutput list and ComposeProductMeta (errors + optimization results).
Derivable fields (avg_return_pct, cumulative_return_pct, n_artifacts) are folds over results.
"""
from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Product.Eval.Output.default import EvalProductOutput
from Types.Product.Compose.Meta.default import ComposeProductMeta
import uuid


class ComposeStatus(str, Enum):
    """Pipeline outcome — success (all windows clean), partial (some errors), failed (no results)."""
    success = "success"
    partial = "partial"
    failed = "failed"


class ComposeProductOutput(BaseModel):
    """ComposeProductOutput [Product] — Result of full pipeline: Discovery -> Ingest -> Feature -> (Train -> Eval)*."""
    session_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    n_windows: int = Field(ge=0, le=10_000, description="Number of walk-forward windows evaluated")
    win_rate_pct: float = Field(ge=0.0, le=100.0, description="Percentage of windows that met the profit threshold")
    duration_s: float = Field(ge=0.0, le=86400.0, description="Total pipeline wall-clock time in seconds")
    status: ComposeStatus = Field(default=ComposeStatus.success, description="Pipeline outcome — success, partial, or failed")
    results: list[EvalProductOutput] = Field(default_factory=list, max_length=10_000, description="Per-window evaluation results")
    meta: ComposeProductMeta = Field(default_factory=ComposeProductMeta, description="Pipeline metadata: errors + optimization results")
