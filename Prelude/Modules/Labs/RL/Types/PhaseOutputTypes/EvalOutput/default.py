"""EvalOutput [Gas] — Eval phase output (7 params). Self-contained."""
from pydantic import BaseModel, Field, constr
import uuid

RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
Ticker = constr(pattern=r"^[A-Z0-9\-./]{1,16}$", min_length=1, max_length=16)


class EvalOutput(BaseModel):
    """EvalOutput [Gas] — Result of out-of-sample evaluation: return, position, and threshold status."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    io_ticker: Ticker = Field(..., description="Ticker symbol that was evaluated")
    window_index: int = Field(ge=0, le=10_000, description="Walk-forward window index for this evaluation")
    portfolio_return_pct: float = Field(ge=-100.0, le=1000.0, description="Portfolio return as percentage — negative means loss")
    final_value: float = Field(ge=0.0, le=1e9, description="Portfolio value in USD at end of evaluation window")
    threshold_met: bool = Field(default=False, description="Whether take-profit threshold was reached during evaluation")
    position: float = Field(ge=-10.0, le=10.0, description="Final position size — 0.0 is flat/cash, 1.0 is fully long")
