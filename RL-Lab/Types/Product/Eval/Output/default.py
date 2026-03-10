"""EvalProductOutput [Product] — Eval phase output (7 fields). Self-contained.

Aliases dissolved — constraints inlined on fields.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Product.Eval.Meta.default import EvalProductMeta
import uuid


class EvalProductOutput(BaseModel):
    """EvalProductOutput [Product] — Result of out-of-sample evaluation: return, position, and threshold status."""
    session_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    io_ticker: Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)] = Field(
        ..., description="Ticker symbol that was evaluated")
    window_index: int = Field(ge=0, le=10_000,
        description="Walk-forward window index for this evaluation")
    portfolio_return_pct: float = Field(ge=-100.0, le=1000.0,
        description="Portfolio return as percentage — negative means loss")
    final_value: float = Field(ge=0.0, le=1e9,
        description="Portfolio value in USD at end of evaluation window")
    threshold_met: bool = Field(default=False,
        description="Whether take-profit threshold was reached during evaluation")
    meta: EvalProductMeta = Field(default_factory=EvalProductMeta,
        description="Eval metadata: observability + audit")
