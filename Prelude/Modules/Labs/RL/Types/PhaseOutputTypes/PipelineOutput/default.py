"""PipelineOutput [Gas] — Full pipeline output (≤7 params). All bounded.

Returns in percentage. Composes EvalOutput list and ErrorUnit list.
duration_s and status absorbed from former RunOutput.
Derivable fields (avg_return_pct, cumulative_return_pct, n_artifacts) are folds over results.
"""
from enum import Enum
from pydantic import BaseModel, Field, constr
from Types.PhaseOutputTypes.EvalOutput.default import EvalOutput
from Types.UnitTypes.ErrorUnit.default import ErrorUnit
import uuid


RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)


class PipelineStatus(str, Enum):
    """Pipeline outcome — success (all windows clean), partial (some errors), failed (no results)."""
    success = "success"
    partial = "partial"
    failed = "failed"


class PipelineOutput(BaseModel):
    """PipelineOutput [Gas] — Result of full pipeline: Discovery → Ingest → Feature → (Train → Eval)*."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    n_windows: int = Field(ge=0, le=10_000, description="Number of walk-forward windows evaluated")
    win_rate_pct: float = Field(ge=0.0, le=100.0, description="Percentage of windows that met the profit threshold")
    duration_s: float = Field(ge=0.0, le=86400.0, description="Total pipeline wall-clock time in seconds")
    status: PipelineStatus = Field(default=PipelineStatus.success, description="Pipeline outcome — success, partial, or failed")
    results: list[EvalOutput] = Field(default_factory=list, max_length=10_000, description="Per-window evaluation results")
    errors: list[ErrorUnit] = Field(default_factory=list, max_length=10_000, description="Errors encountered during pipeline execution")
