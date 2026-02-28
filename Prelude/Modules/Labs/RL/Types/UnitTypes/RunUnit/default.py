"""RunUnit [Solid] — Run context (7 params). Plain BaseModel.

Composed into Config. Not a pydantic-settings model.
"""
from datetime import datetime, timezone
from enum import Enum
from pydantic import BaseModel, Field, constr
import uuid


class RunStatus(str, Enum):
    """Pipeline execution status — tracks lifecycle from pending to completion or failure."""
    pending = "pending"
    running = "running"
    success = "success"
    partial = "partial"
    failed = "failed"


RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
RunName = constr(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$")
DirPath = constr(min_length=1, max_length=256, pattern=r"^[A-Za-z0-9_\-./]+$")
RunTs = constr(pattern=r"^\d{8}-\d{4}$", min_length=13, max_length=13)


class RunUnit(BaseModel):
    """RunUnit [Solid] — Run identity and execution context shared across all phases."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier — auto-generated UUID prefix")
    run_ts: RunTs = Field(default_factory=lambda: datetime.now(timezone.utc).strftime("%Y%m%d-%H%M"), description="UTC timestamp at minute granularity — YYYYMMDD-HHMM, for output file sorting")
    seed: int = Field(default=42, ge=0, le=2_147_483_647, description="Random seed for reproducibility across numpy/torch")
    name: RunName = Field(default="run", description="Human-readable run label for output file naming")
    output_dir: DirPath = Field(default="Env/output", description="Directory path for all phase output artifacts")
    status: RunStatus = Field(default=RunStatus.pending, description="Current pipeline execution status")
    verbose: int = Field(default=0, ge=0, le=2, description="Logging verbosity — 0 silent, 1 summary, 2 debug")
