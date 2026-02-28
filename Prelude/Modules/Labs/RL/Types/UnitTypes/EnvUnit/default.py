"""EnvUnit [Solid] — Shared gym-trading-env params (7 params). All bounded.

Train/Eval/Infer symmetry. Stop-loss via native limit orders.
"""
from enum import Enum
from pydantic import BaseModel, Field, constr


class BrokerMode(str, Enum):
    """Execution mode — sim for backtesting, paper for dry-run, live for real trades."""
    sim = "sim"
    paper = "paper"
    live = "live"


BrokerKey = constr(min_length=1, max_length=256, pattern=r"^[A-Za-z0-9_\-]+$")


class EnvUnit(BaseModel):
    """EnvUnit [Solid] — Trading environment parameters shared across train, eval, and infer."""
    initial_value: float = Field(default=10_000.0, ge=100.0, le=1e8, description="Starting portfolio value in USD")
    fees_pct: float = Field(default=0.1, ge=0.0, le=10.0, description="Trading fee per transaction as percentage of trade value")
    borrow_rate_pct: float = Field(default=0.0, ge=0.0, le=10.0, description="Annualized borrow rate for short positions as percentage")
    positions: list[float] = Field(default=[0.0, 1.0], min_length=2, max_length=10, description="Allowed position sizes — 0.0 is flat/cash, 1.0 is fully long")
    broker_mode: BrokerMode = Field(default=BrokerMode.sim, description="Execution mode — sim (backtest), paper (dry-run), or live")
    io_broker_key: BrokerKey = Field(default="sim", description="Broker API key identifier — required for paper/live modes")
    stop_loss_pct: float = Field(default=-2.0, ge=-100.0, le=0.0, description="Per-step stop-loss trigger as negative percentage of portfolio")
