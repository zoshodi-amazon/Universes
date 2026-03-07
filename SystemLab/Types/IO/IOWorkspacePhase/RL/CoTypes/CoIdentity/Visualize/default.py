"""VisualizeCoHom [CoHom] — Rerun multi-modal observer config (5 fields). All bounded.

Liquid-dual phase — the dual of a Hom type. Where Hom types are morphisms
flowing INTO a phase (constructors), CoHom types are morphisms flowing OUT
from an observation source (destructors / observation configs).

VisualizeCoHom configures the scan-and-render operation over StoreMonad artifacts:
  extract : StoreMonad.all_runs() → ScalarSeriesSet → RenderScene

Fields satisfy Independence, Completeness, Locality:
- db_url:           SQLAlchemy URL for the artifact store — filesystem coordinate
- recording_id:     Rerun recording label — empty = derived from latest run_id
- spawn_viewer:     native window launch — independent of web serving
- serve_web:        web viewer endpoint — independent of native window
- include_features: whether to log feature DataFrames — orthogonal fidelity axis
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class VisualizeCoHom(BaseModel):
    """VisualizeCoHom [CoHom] — Configuration for the Rerun multi-modal artifact observer (5 fields)."""
    db_url: Annotated[str, StringConstraints(min_length=1, max_length=512)] = Field(
        default="sqlite:///store/.rl.db",
        description="SQLAlchemy URL for the StoreMonad artifact DB — scans all_runs() for phase outputs")
    recording_id: Annotated[str, StringConstraints(min_length=0, max_length=64, pattern=r"^[A-Za-z0-9_\-]*$")] = Field(
        default="",
        description="Rerun recording label — empty string means auto-derive from latest run_id found")
    spawn_viewer: bool = Field(default=False,
        description="Launch native Rerun viewer window — requires a display; off by default for tmux environments")
    serve_web: bool = Field(default=True,
        description="Serve Rerun web viewer at localhost:9090 — tmux-compatible default")
    include_features: bool = Field(default=False,
        description="Log feature DataFrames to Rerun — high fidelity but slow for large runs; off by default")
