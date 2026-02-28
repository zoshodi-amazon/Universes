"""PythonRunRecord — Standardized pipeline output artifact (7 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class RunStatus(str, Enum):
    success = "success"; partial = "partial"; failed = "failed"; skipped = "skipped"
class RunRecord(BaseModel):
    pipeline: str = Field(description="Pipeline name that produced this record")
    timestamp: str = Field(default="1970-01-01T00:00:00Z", description="ISO8601")
    duration_s: float = Field(default=0.0, ge=0.0)
    status: RunStatus = RunStatus.success
    params_hash: str = Field(default="0" * 8, description="Hash of input params")
    artifacts_produced: list[str] = Field(default=[])
    errors: list[str] = Field(default=[])
