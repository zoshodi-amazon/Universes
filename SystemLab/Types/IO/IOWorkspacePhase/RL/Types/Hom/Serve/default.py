"""ServeHom [Hom] — Serve phase config (5 fields). All bounded.

io_model_path and io_normalize_path removed: both were manual filesystem pointers
that forced the caller to know blob locations. Serve now queries StoreMonad by
(train_run_id, phase="train", artifact_type="model"|"normalize") — the DB is the index.

broker_mode removed: belongs on EnvDependent (Field Locality). All IO executors
read broker_mode from env_base.broker_mode — it is a trading environment parameter,
not a serving morphism parameter.

Fields satisfy Independence, Completeness, Locality:
- train_run_id:       which trained model to serve — DB lookup key, independent of serving config
- io_algo:            algorithm hint for SB3 dispatch — independent of run_id
- poll_interval_s:    bar polling cadence — independent axis
- max_bars:           session length cap — independent of polling cadence
- max_model_age_min:  staleness gate — independent of session length
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Inductive.Algo.default import AlgoIdentity


class ServeHom(BaseModel):
    """ServeHom [Hom] — Config for live bar-by-bar model serving with broker execution (5 fields)."""
    train_run_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        ..., description="run_id of the training run to serve — StoreMonad looks up model + normalize blobs by this key")
    io_algo: AlgoIdentity = Field(default=AlgoIdentity.PPO,
        description="RL algorithm used for the trained model — must match training algo")
    poll_interval_s: int = Field(default=60, ge=5, le=300,
        description="Seconds between bar fetch attempts — 60 for 1m polling")
    max_bars: int = Field(default=288, ge=1, le=10_000,
        description="Max bars before graceful shutdown — 288 = one 5m trading day")
    max_model_age_min: int = Field(default=1440, ge=1, le=100_000,
        description="Max model age in minutes before position is zeroed — 1440 = one day")
