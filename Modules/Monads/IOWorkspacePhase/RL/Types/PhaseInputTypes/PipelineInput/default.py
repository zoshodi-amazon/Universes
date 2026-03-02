"""PipelineInput [Liquid] — Pipeline phase config (≤7 params). All bounded.

Controls walk-forward windowing for the full Discovery → Ingest → Feature → (Train → Eval)* pipeline.
Time in minutes.
"""
from pydantic import BaseModel, Field


class PipelineInput(BaseModel):
    """PipelineInput [Liquid] — Config for rolling walk-forward window sizing in the full pipeline."""
    stride_min: int = Field(default=1440, ge=60, le=100_000, description="Step size between windows in minutes — 1440 = slide one day at a time")
    train_split_pct: float = Field(default=80.0, ge=10.0, le=95.0, description="Percentage of data used for training vs held-out evaluation")
