"""ServeInput [Liquid] — Serve phase config (≤7 params). All bounded."""
from pydantic import BaseModel, Field, constr


FilePath = constr(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./]+$")


class ServeInput(BaseModel):
    """ServeInput [Liquid] — Config for live bar-by-bar model serving with broker execution."""
    poll_interval_s: int = Field(default=60, ge=5, le=300, description="Seconds between bar fetch attempts — 60 for 1m polling")
    max_bars: int = Field(default=288, ge=1, le=10_000, description="Max bars before graceful shutdown — 288 = one 5m trading day")
    profit_threshold_pct: float = Field(default=0.5, ge=0.0, le=100.0, description="Take-profit trigger as percentage return on portfolio")
    io_model_path: FilePath = Field(..., description="File path to the trained SB3 model zip")
    io_normalize_path: FilePath = Field(..., description="File path to the saved VecNormalize running stats pickle")
