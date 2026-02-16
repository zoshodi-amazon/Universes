"""PythonRunBase — Runtime params artifact (5 params)"""
from pydantic import BaseModel, Field
class RunBase(BaseModel):
    dry_run: bool = False
    verbose: bool = False
    timeout_s: float = Field(default=300.0, gt=0.0, le=86400.0)
    parallel: int = Field(default=1, ge=1, le=32)
    force: bool = False
