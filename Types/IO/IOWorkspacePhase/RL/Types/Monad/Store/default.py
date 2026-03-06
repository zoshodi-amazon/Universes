"""StoreMonad [Monad] — Typed artifact store: SQLite metadata + filesystem blobs (5 fields).

Plasma phase — effectful IO composition over a content-addressed artifact store.
Replaces the ad-hoc EnvBoundary + io_*_path field system. Where ObservabilityMonad
records what happened inside a phase, StoreMonad manages what a phase produced
and how subsequent phases retrieve it.

The DB is a single `artifacts` table:
    run_id, phase, artifact_type, blob_path, metadata_json, created_at

Blob layout on disk:
    {blob_dir}/{run_id}/{phase}_{artifact_type}.{ext}

Monad operations (bind/return pattern over IO effects):
    put(artifact_type, blob_path, metadata) → inserts/replaces DB row
    get(run_id, phase, artifact_type)       → ArtifactRow (raises if not found)
    latest(phase, artifact_type)            → most recent row across all run_ids

Fields satisfy Independence, Completeness, Locality:
- db_url:     where the DB lives — independent of blob storage location
- blob_dir:   root for binary blobs — independent of DB URL
- run_id:     scopes put() writes — independent of connection config
- phase:      scopes put() writes — independent of run_id
- docs_dir:   subdirectory for docs/tracker logs — independent of artifact blobs

Default db_url uses SQLite at store/.rl.db — spin up is automatic (no server needed).
Any SQLAlchemy-compatible URL works: postgresql://..., etc.
"""
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints

from Types.Monad.Error.default import PhaseId

_Path = Annotated[str, StringConstraints(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./: @]+$")]
_Url  = Annotated[str, StringConstraints(min_length=1, max_length=512)]


class ArtifactRow(BaseModel):
    """ArtifactRow — Single row returned from StoreMonad.get() / .latest() (6 fields)."""
    run_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        description="Run identifier that produced this artifact")
    phase: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        description="Phase name that produced this artifact")
    artifact_type: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        description="Artifact kind — e.g. 'ingest', 'model', 'normalize', 'features', 'discovery'")
    blob_path: Annotated[str, StringConstraints(min_length=0, max_length=512)] = Field(
        default="",
        description="Absolute or relative path to binary blob — empty for metadata-only artifacts")
    metadata_json: Annotated[str, StringConstraints(min_length=2)] = Field(
        default="{}",
        description="Full ProductOutput model_dump_json() for this artifact")
    created_at: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        description="ISO timestamp when this artifact was written")


class StoreMonad(BaseModel):
    """StoreMonad [Monad] — Typed artifact store binding DB metadata to filesystem blobs (5 fields)."""
    db_url: _Url = Field(
        default="sqlite:///store/.rl.db",
        description="SQLAlchemy DB URL — default SQLite at store/.rl.db; swappable to any engine")
    blob_dir: _Path = Field(
        default="store/blobs",
        description="Root directory for binary artifact blobs — layout: {blob_dir}/{run_id}/{phase}_{artifact_type}.{ext}")
    run_id: Annotated[str, StringConstraints(min_length=1, max_length=64, pattern=r"^[a-f0-9]{8}$")] = Field(
        default="00000000",
        description="Current run identifier — scopes all put() writes; overridden at runtime by RunIdentity.run_id")
    phase: PhaseId = Field(
        default=PhaseId.pipeline,
        description="Current phase — scopes put() writes; overridden at runtime by each IO executor")
    docs_dir: _Path = Field(
        default="store/docs",
        description="Directory for docs and tracker logs — independent of artifact blobs")

    # ------------------------------------------------------------------
    # Internal helpers — not fields, not validators. Keep side-effect-free
    # until explicitly called by IO executors.
    # ------------------------------------------------------------------

    def _engine(self):
        """Return a SQLAlchemy engine, creating the DB and table if needed."""
        from sqlalchemy import create_engine, text
        url = self.db_url
        # SQLite: ensure parent directory exists
        if url.startswith("sqlite:///"):
            db_path = Path(url[len("sqlite:///"):])
            db_path.parent.mkdir(parents=True, exist_ok=True)
        engine = create_engine(url)
        with engine.connect() as conn:
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS artifacts (
                    id            INTEGER PRIMARY KEY AUTOINCREMENT,
                    run_id        TEXT NOT NULL,
                    phase         TEXT NOT NULL,
                    artifact_type TEXT NOT NULL,
                    blob_path     TEXT NOT NULL DEFAULT '',
                    metadata_json TEXT NOT NULL DEFAULT '{}',
                    created_at    TEXT NOT NULL,
                    UNIQUE(run_id, phase, artifact_type)
                )
            """))
            conn.execute(text(
                "CREATE INDEX IF NOT EXISTS idx_run_phase ON artifacts(run_id, phase)"
            ))
            conn.commit()
        return engine

    def blob_path_for(self, artifact_type: str, ext: str = "pkl") -> Path:
        """Compute the canonical blob path for this run/phase/artifact_type."""
        root = Path(self.blob_dir) / self.run_id
        root.mkdir(parents=True, exist_ok=True)
        return root / f"{self.phase.value}_{artifact_type}.{ext}"

    def put(self, artifact_type: str, metadata: BaseModel, blob_path: str = "") -> None:
        """Bind: write artifact metadata row to DB (and optionally record blob path).

        INSERT OR REPLACE so re-runs of the same (run_id, phase, artifact_type)
        update in place rather than accumulating stale rows.
        """
        from sqlalchemy import text
        engine = self._engine()
        now = datetime.now(timezone.utc).isoformat()
        meta_json = metadata.model_dump_json()
        with engine.connect() as conn:
            conn.execute(text("""
                INSERT INTO artifacts(run_id, phase, artifact_type, blob_path, metadata_json, created_at)
                VALUES (:run_id, :phase, :artifact_type, :blob_path, :metadata_json, :created_at)
                ON CONFLICT(run_id, phase, artifact_type) DO UPDATE SET
                    blob_path     = excluded.blob_path,
                    metadata_json = excluded.metadata_json,
                    created_at    = excluded.created_at
            """), {
                "run_id":        self.run_id,
                "phase":         self.phase.value,
                "artifact_type": artifact_type,
                "blob_path":     blob_path,
                "metadata_json": meta_json,
                "created_at":    now,
            })
            conn.commit()

    def get(self, run_id: str, phase: str, artifact_type: str) -> ArtifactRow:
        """Extract: retrieve artifact row by (run_id, phase, artifact_type). Raises if not found."""
        from sqlalchemy import text
        engine = self._engine()
        with engine.connect() as conn:
            row = conn.execute(text("""
                SELECT run_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                WHERE run_id = :run_id AND phase = :phase AND artifact_type = :artifact_type
            """), {"run_id": run_id, "phase": phase, "artifact_type": artifact_type}).fetchone()
        if row is None:
            raise KeyError(
                f"StoreMonad.get: no artifact ({run_id}, {phase}, {artifact_type}) in {self.db_url}"
            )
        return ArtifactRow(
            run_id=row[0], phase=row[1], artifact_type=row[2],
            blob_path=row[3], metadata_json=row[4], created_at=row[5],
        )

    def latest(self, phase: str, artifact_type: str) -> ArtifactRow:
        """Extract: retrieve most recently written artifact for (phase, artifact_type) across all runs."""
        from sqlalchemy import text
        engine = self._engine()
        with engine.connect() as conn:
            row = conn.execute(text("""
                SELECT run_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                WHERE phase = :phase AND artifact_type = :artifact_type
                ORDER BY created_at DESC LIMIT 1
            """), {"phase": phase, "artifact_type": artifact_type}).fetchone()
        if row is None:
            raise KeyError(
                f"StoreMonad.latest: no artifact ({phase}, {artifact_type}) in {self.db_url}"
            )
        return ArtifactRow(
            run_id=row[0], phase=row[1], artifact_type=row[2],
            blob_path=row[3], metadata_json=row[4], created_at=row[5],
        )

    def all_runs(self) -> list[ArtifactRow]:
        """Extract: return all artifact rows ordered by created_at DESC — used by IOVisualizePhase."""
        from sqlalchemy import text
        engine = self._engine()
        with engine.connect() as conn:
            rows = conn.execute(text("""
                SELECT run_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                ORDER BY created_at DESC
            """)).fetchall()
        return [
            ArtifactRow(
                run_id=r[0], phase=r[1], artifact_type=r[2],
                blob_path=r[3], metadata_json=r[4], created_at=r[5],
            )
            for r in rows
        ]
