"""PythonAlloy — Material composition artifact (3 params)"""
from pydantic import BaseModel, Field
class Alloy(BaseModel):
    elements: int = Field(default=2, ge=1, le=10)
    primary_pct: float = Field(default=90.0, ge=0.0, le=100.0)
    process_temp_c: float = Field(default=1000.0, ge=0.0, le=5000.0)
