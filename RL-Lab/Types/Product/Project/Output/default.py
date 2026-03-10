"""ProjectProductOutput [Product] — Serve phase output (7 fields). All bounded.

Aliases dissolved — constraints inlined on fields.
"""
from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Product.Project.Meta.default import ProjectProductMeta
import uuid


class ProjectStatus(str, Enum):
    """Serve session outcome — running, completed normally, stopped by risk gate, or failed."""
    running = "running"
    completed = "completed"
    stopped = "stopped"
    failed = "failed"


class ProjectProductOutput(BaseModel):
    """ProjectProductOutput [Product] — Result of live serving session: bars processed, trades made, final position."""
    session_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    io_ticker: Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)] = Field(
        ..., description="Ticker symbol being served")
    n_bars_served: int = Field(ge=0, le=10_000,
        description="Number of live bars processed in this session")
    portfolio_return_pct: float = Field(ge=-100.0, le=1000.0,
        description="Cumulative portfolio return as percentage for this session")
    position_taken: float = Field(ge=-10.0, le=10.0,
        description="Final position at session end — 0.0 is flat/cash, 1.0 is fully long")
    status: ProjectStatus = Field(default=ProjectStatus.running,
        description="Session outcome — running, completed, stopped, or failed")
    meta: ProjectProductMeta = Field(default_factory=ProjectProductMeta,
        description="Serve metadata: observability + audit")
