"""EnvDependent [Dependent] — Trading environment parameters (6 fields). All bounded.

stop_loss_pct moved to RiskDependent to centralise risk gate parameters.
Shared across Train, Eval, and Serve phases.

Fields satisfy Independence, Completeness, Locality:
- initial_value:   starting portfolio size — independent axis
- fees_pct:        per-trade friction — independent axis
- borrow_rate_pct: short position cost — independent axis
- positions:       allowed position set — independent axis
- broker_mode:     execution mode — independent axis
- io_broker_key:   broker API credential — only live when broker_mode != sim,
                   sentinel "sim" makes intent clear
"""
from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class BrokerMode(str, Enum):
    """Execution mode — sim for backtesting, paper for dry-run, live for real trades."""
    sim = "sim"
    paper = "paper"
    live = "live"


class EnvDependent(BaseModel):
    """EnvDependent [Dependent] — Trading environment parameters shared across train, eval, and serve."""
    initial_value: float = Field(default=10_000.0, ge=100.0, le=1e8,
        description="Starting portfolio value in USD")
    fees_pct: float = Field(default=0.1, ge=0.0, le=10.0,
        description="Trading fee per transaction as percentage of trade value")
    borrow_rate_pct: float = Field(default=0.0, ge=0.0, le=10.0,
        description="Annualized borrow rate for short positions as percentage")
    positions: list[float] = Field(default=[-1.0, 0.0, 1.0], min_length=2, max_length=10,
        description="Allowed position sizes — -1.0 short, 0.0 flat/cash, 1.0 fully long")
    broker_mode: BrokerMode = Field(default=BrokerMode.sim,
        description="Execution mode — sim (backtest), paper (dry-run), or live")
    io_broker_key: Annotated[str, StringConstraints(min_length=1, max_length=256, pattern=r"^[A-Za-z0-9_\-]+$")] = Field(
        default="sim",
        description="Broker API key identifier — required for paper/live modes, sentinel 'sim' for sim mode")
