"""OptimizeOutput [Gas] — Optimize pipeline output (<=7 params). Self-contained."""
from pydantic import BaseModel, Field
from Types.UnitTypes.FieldUnit.default import RunId, FilePath
import uuid


class OptimizeOutput(BaseModel):
    """OptimizeOutput [Gas] — Result of Optuna hyperparameter search: best trial params, score, and model path."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    n_completed: int = Field(ge=0, le=10_000, description="Number of Optuna trials that completed successfully")
    io_model_path: FilePath = Field(..., description="File path to the best trial's trained SB3 model zip")
    best_lr: float = Field(ge=1e-8, le=1.0, description="Learning rate of the best-performing trial")
    best_timesteps: int = Field(ge=100, le=100_000_000, description="Total timesteps of the best-performing trial")
    best_win_rate_pct: float = Field(ge=0.0, le=100.0, description="Win rate percentage of the best-performing trial")
    io_study_path: FilePath = Field(..., description="File path to the Optuna JournalStorage log file")
