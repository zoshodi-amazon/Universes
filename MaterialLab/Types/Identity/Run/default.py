"""RunIdentity [Identity] — terminal object, BEC phase.

Terminal object for a single pipeline run in the MaterialLab type universe.
Captures the run's unique identifier, timestamp, reproducibility seed, and
logging configuration. No optional fields; sentinels used where absence
must be representable (name defaults to "").
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class RunIdentity(BaseModel):
    """Terminal identity for a single pipeline run."""

    run_id: Annotated[str, StringConstraints(min_length=8, max_length=8)] = Field(
        description="Auto-generated 8-character hex identifier from UUID prefix."
    )
    run_ts: Annotated[str, StringConstraints(min_length=15, max_length=15)] = Field(
        description="Run timestamp in YYYYMMDD-HHMM format (15 chars with separators)."
    )
    seed: int = Field(
        ge=0,
        le=2**31,
        description="Reproducibility seed for deterministic pipeline execution.",
    )
    name: Annotated[str, StringConstraints(min_length=0, max_length=128)] = Field(
        default="",
        description="Human-readable run name; sentinel '' when unset.",
    )
    verbose: bool = Field(
        description="Enable verbose logging for this run.",
    )
