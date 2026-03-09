"""TraceComonad [Comonad] — Coalgebraic observation cursor (5 fields). All bounded.

Plasma-dual phase — the dual of ObservabilityMonad.
Where ObservabilityMonad records effects that happened (errors, metrics, alarms),
TraceComonad records the observation cursor state: where in the stream/artifact
space the observer currently is.

Comonad laws (categorical dual of Monad):
  extract : W A → A           (dual of return  : A → M A)
  extend  : (W A → B) → W B   (dual of bind    : M A → (A → M B) → M B)

extract(TraceComonad) → cursor  (current observation point)
extend(f)(tc)         → new TraceComonad after applying observation function f

Fields satisfy Independence, Completeness, Locality:
- observer_id:   identity of this observer instance — unique per executor run
- cursor:        current position in stream/scan space — SSE last_event_id or last filepath
- events_seen:   total items observed so far — monotonically increasing counter
- connection_ok: liveness of the source — independent boolean axis
- last_seen_at:  ISO timestamp of most recent observation — temporal coordinate
"""

from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class CoPhaseId(str, Enum):
    """Observer phase identifier — which coalgebraic executor produced this trace.

    Dual of PhaseId in Types/Monad/Error/ — CoPhaseId identifies observer executors,
    not pipeline phases. Observer errors never mix with pipeline errors.
    """

    tail = "tail"
    visualize = "visualize"
    discovery = "discovery"
    ingest = "ingest"
    feature = "feature"
    train = "train"
    eval = "eval"
    serve = "serve"
    main = "main"
    validate = "validate"


class TraceComonad(BaseModel):
    """TraceComonad [Comonad] — Coalgebraic observation cursor composable into any observer (5 fields)."""

    observer_id: Annotated[
        str,
        StringConstraints(min_length=1, max_length=64, pattern=r"^[A-Za-z0-9_\-]+$"),
    ] = Field(
        default="observer",
        description="Identity of this observer instance — unique per executor run",
    )
    cursor: Annotated[str, StringConstraints(min_length=0, max_length=512)] = Field(
        default="",
        description="Current position in observation space — SSE last_event_id or last file path scanned; empty = not started",
    )
    events_seen: int = Field(
        default=0,
        ge=0,
        le=10_000_000,
        description="Total items observed so far — monotonically increasing counter",
    )
    connection_ok: bool = Field(
        default=True,
        description="Liveness of the observation source — False when source is unreachable",
    )
    last_seen_at: Annotated[str, StringConstraints(max_length=32)] = Field(
        default="",
        description="ISO timestamp of most recent observation — empty if nothing observed yet",
    )
