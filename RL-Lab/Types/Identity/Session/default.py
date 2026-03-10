"""SessionIdentity [Identity] — Run context (5 fields).

BEC phase — terminal object answering "what run exists?"
Composed into every phase Settings. Not a pydantic-settings model.

Fields satisfy Independence, Completeness, Locality:
- session_id:  who   — unique identifier for this run
- session_ts:  when  — UTC timestamp at minute granularity
- seed:    reproducibility — RNG seed for numpy/torch
- name:    label — human-readable run label
- verbose: execution behaviour — logging verbosity level

StoreMonad lifted to IO layer (Settings) — Identity does not import Monad.
status removed (mutable runtime state belongs in ProductMeta outputs, not input identity).
"""

import uuid
from datetime import datetime, timezone
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class SessionIdentity(BaseModel):
    """SessionIdentity [Identity] — Run identification and execution context shared across all phases (5 fields)."""

    session_id: Annotated[
        str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
    ] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier — auto-generated UUID prefix",
    )
    session_ts: Annotated[
        str, StringConstraints(pattern=r"^\d{8}-\d{4}$", min_length=13, max_length=13)
    ] = Field(
        default_factory=lambda: datetime.now(timezone.utc).strftime("%Y%m%d-%H%M"),
        description="UTC timestamp at minute granularity — YYYYMMDD-HHMM for output file sorting",
    )
    seed: int = Field(
        default=42,
        ge=0,
        le=2_147_483_647,
        description="Random seed for reproducibility across numpy/torch",
    )
    name: Annotated[
        str,
        StringConstraints(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$"),
    ] = Field(
        default="run", description="Human-readable run label for output file naming"
    )
    verbose: int = Field(
        default=0,
        ge=0,
        le=2,
        description="Logging verbosity — 0 silent, 1 summary, 2 debug",
    )
