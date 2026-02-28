"""ServeInput [Liquid] — Serve phase config (≤7 params). All bounded."""
from pydantic import BaseModel, Field
from Types.UnitTypes.FieldUnit.default import FilePath
from Types.PhaseInputTypes.TrainInput.default import AlgoName


class ServeInput(BaseModel):
    """ServeInput [Liquid] — Config for live bar-by-bar model serving with broker execution."""
    io_model_path: FilePath = Field(..., description="File path to the trained SB3 model zip")
    io_normalize_path: FilePath = Field(..., description="File path to the saved VecNormalize running stats pickle")
    io_algo: AlgoName = Field(default=AlgoName.PPO, description="RL algorithm used for the trained model — must match training algo")
    poll_interval_s: int = Field(default=60, ge=5, le=300, description="Seconds between bar fetch attempts — 60 for 1m polling")
    max_bars: int = Field(default=288, ge=1, le=10_000, description="Max bars before graceful shutdown — 288 = one 5m trading day")
    profit_threshold_pct: float = Field(default=0.5, ge=0.0, le=100.0, description="Take-profit trigger as percentage return on portfolio")
    max_model_age_min: int = Field(default=1440, ge=1, le=100_000, description="Max model age in minutes before position is zeroed — 1440 = one day")
