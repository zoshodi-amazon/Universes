"""TailCoHom [CoHom] — Tail observer config (3 fields). All bounded.

Liquid-dual phase — the dual of a Hom type. Where Hom types are morphisms
flowing INTO a phase (constructors), CoHom types are morphisms flowing OUT
from an observation source (destructors / observation configs).

TailCoHom configures the extract operation on the OpenCode SSE event stream:
  extract : SSEStream → FilteredEventSequence

Fields satisfy Independence, Completeness, Locality:
- port:          network address coordinate — independent of hostname
- hostname:      network address coordinate — independent of port
- filter_kinds:  event kind prefixes to display — orthogonal selection axis
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class TailCoHom(BaseModel):
    """TailCoHom [CoHom] — Configuration for the SSE event stream observer (3 fields)."""
    port: int = Field(default=4096, ge=1024, le=65535,
        description="OpenCode server port — start opencode with --port 4096")
    hostname: Annotated[str, StringConstraints(min_length=1, max_length=253, pattern=r"^[A-Za-z0-9.\-]+$")] = Field(
        default="127.0.0.1",
        description="OpenCode server hostname — 127.0.0.1 for local sessions")
    filter_kinds: list[Annotated[str, StringConstraints(min_length=1, max_length=64)]] = Field(
        default=["tool", "file", "message"],
        min_length=1, max_length=20,
        description="Event kind prefixes to display — events whose kind starts with any of these are shown")
