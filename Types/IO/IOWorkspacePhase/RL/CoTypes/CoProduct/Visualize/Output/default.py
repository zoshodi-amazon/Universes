"""VisualizeCoProductOutput [CoProduct] — Rerun observer output (7 fields). All bounded.

Gas-dual phase — the dual of a ProductOutput type. Where ProductOutput records
what a phase produced, CoProductOutput records what an observer saw.

extract(VisualizeCoProductOutput) → the scalar series and text logged to Rerun.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid

from CoTypes.CoProduct.Visualize.Meta.default import VisualizeCoProductMeta


class VisualizeCoProductOutput(BaseModel):
    """VisualizeCoProductOutput [CoProduct] — Result of Rerun artifact observation run (7 fields)."""
    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$")] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex observer instance identifier")
    n_phases_logged: int = Field(default=0, ge=0, le=100,
        description="Number of distinct phase artifact types logged to Rerun")
    n_series_logged: int = Field(default=0, ge=0, le=100_000,
        description="Total number of scalar series logged to Rerun")
    n_errors_logged: int = Field(default=0, ge=0, le=100_000,
        description="Total number of error records logged as Rerun text entries")
    io_rrd_path: Annotated[str, StringConstraints(min_length=0, max_length=512)] = Field(
        default="",
        description="Path to saved .rrd Rerun recording file — empty string if not saved to disk")
    viewer_url: Annotated[str, StringConstraints(min_length=0, max_length=256)] = Field(
        default="",
        description="URL of Rerun web viewer — e.g. http://localhost:9090 — empty if serve_web=False")
    meta: VisualizeCoProductMeta = Field(
        default_factory=VisualizeCoProductMeta,
        description="Observer metadata — trace cursor, run_ids found, phases found, feature columns logged")
