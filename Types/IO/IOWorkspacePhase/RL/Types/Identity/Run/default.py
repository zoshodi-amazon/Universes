"""RunIdentity [Identity] — Run context (6 fields).

BEC phase — terminal object answering "what run exists?"
Composed into every phase Settings. Not a pydantic-settings model.

Fields satisfy Independence, Completeness, Locality:
- run_id:  who   — unique identifier for this run
- run_ts:  when  — UTC timestamp at minute granularity
- seed:    reproducibility — RNG seed for numpy/torch
- name:    label — human-readable run label
- store:   where — typed artifact store (DB + blob dir); replaces ad-hoc Env/ dir
- verbose: execution behaviour — logging verbosity level

EnvBoundary removed: replaced by StoreMonad which provides a typed DB-backed
artifact store. The store field carries both the DB URL and blob root dir —
a single typed coordinate chart for all IO boundary concerns.
status removed (mutable runtime state belongs in ProductMeta outputs, not input identity).
"""
import uuid
from datetime import datetime, timezone
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Monad.Store.default import StoreMonad


class RunIdentity(BaseModel):
    """RunIdentity [Identity] — Run identification and execution context shared across all phases (6 fields)."""
    run_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier — auto-generated UUID prefix")
    run_ts: Annotated[str, StringConstraints(pattern=r"^\d{8}-\d{4}$", min_length=13, max_length=13)] = Field(
        default_factory=lambda: datetime.now(timezone.utc).strftime("%Y%m%d-%H%M"),
        description="UTC timestamp at minute granularity — YYYYMMDD-HHMM for output file sorting")
    seed: int = Field(default=42, ge=0, le=2_147_483_647,
        description="Random seed for reproducibility across numpy/torch")
    name: Annotated[str, StringConstraints(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$")] = Field(
        default="run",
        description="Human-readable run label for output file naming")
    store: StoreMonad = Field(
        default_factory=StoreMonad,
        description="Typed artifact store — DB URL + blob dir; replaces ad-hoc Env/ filesystem boundary")
    verbose: int = Field(default=0, ge=0, le=2,
        description="Logging verbosity — 0 silent, 1 summary, 2 debug")
