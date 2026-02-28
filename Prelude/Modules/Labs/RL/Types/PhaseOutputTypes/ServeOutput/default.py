"""ServeOutput [Gas] — Serve phase output (≤7 params). All bounded."""
from enum import Enum
from pydantic import BaseModel, Field, constr
import uuid


RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
Ticker = constr(pattern=r"^[A-Z0-9\-./]{1,16}$", min_length=1, max_length=16)


class ServeStatus(str, Enum):
    """Serve session outcome — running, completed normally, stopped by risk gate, or failed."""
    running = "running"
    completed = "completed"
    stopped = "stopped"
    failed = "failed"


class ServeOutput(BaseModel):
    """ServeOutput [Gas] — Result of live serving session: bars processed, trades made, final position."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    io_ticker: Ticker = Field(..., description="Ticker symbol being served")
    n_bars_served: int = Field(ge=0, le=10_000, description="Number of live bars processed in this session")
    portfolio_return_pct: float = Field(ge=-100.0, le=1000.0, description="Cumulative portfolio return as percentage for this session")
    position_taken: float = Field(ge=-10.0, le=10.0, description="Final position at session end — 0.0 is flat/cash, 1.0 is fully long")
    n_trades: int = Field(ge=0, le=10_000, description="Number of position changes during this session")
    status: ServeStatus = Field(default=ServeStatus.running, description="Session outcome — running, completed, stopped, or failed")
