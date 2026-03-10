"""StoreMonad [Monad] — Typed artifact store: SQLite metadata + filesystem blobs (5 fields).

Plasma phase — effectful IO composition over a content-addressed artifact store.
Replaces the ad-hoc EnvBoundary + io_*_path field system. Where EffectMonad
records what happened inside a phase, StoreMonad manages what a phase produced
and how subsequent phases retrieve it.

The DB is a single `artifacts` table:
    session_id, phase, artifact_type, blob_path, metadata_json, created_at

Blob layout on disk:
    {blob_dir}/{session_id}/{phase}_{artifact_type}.{ext}

Monad operations (bind/return pattern over IO effects):
    put(artifact_type, blob_path, metadata) -> IOResult[None, Exception]
    get(session_id, phase, artifact_type)   -> Maybe[ArtifactRow]
    latest(phase, artifact_type)            -> Maybe[ArtifactRow]

Fields satisfy Independence, Completeness, Locality:
- db_url:     where the DB lives — independent of blob storage location
- blob_dir:   root for binary blobs — independent of DB URL
- session_id: scopes put() writes — independent of connection config
- phase:      scopes put() writes — independent of session_id
- docs_dir:   subdirectory for docs/tracker logs — independent of artifact blobs

Default db_url uses SQLite at store/.rl.db — spin up is automatic (no server needed).
Any SQLAlchemy-compatible URL works: postgresql://..., etc.
"""

from datetime import datetime, timezone
from pathlib import Path
from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints
from returns.maybe import Maybe, Some, Nothing
from returns.io import IOResult, IOSuccess, IOFailure
from returns.unsafe import unsafe_perform_io

from Types.Monad.Error.default import PhaseId
from Types.Monad.Artifact.default import ArtifactRow


def _row_to_artifact(row: tuple) -> ArtifactRow:
    """Convert a DB row tuple to ArtifactRow."""
    return ArtifactRow(
        session_id=row[0],
        phase=row[1],
        artifact_type=row[2],
        blob_path=row[3],
        metadata_json=row[4],
        created_at=row[5],
    )


class StoreMonad(BaseModel):
    """StoreMonad [Monad] — Typed artifact store binding DB metadata to filesystem blobs (5 fields)."""

    db_url: Annotated[str, StringConstraints(min_length=1, max_length=512)] = Field(
        default="sqlite:///store/.rl.db",
        description="SQLAlchemy DB URL — default SQLite at store/.rl.db; swappable to any engine",
    )
    blob_dir: Annotated[
        str,
        StringConstraints(
            min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./: @]+$"
        ),
    ] = Field(
        default="store/blobs",
        description="Root directory for binary artifact blobs — layout: {blob_dir}/{session_id}/{phase}_{artifact_type}.{ext}",
    )
    session_id: Annotated[
        str, StringConstraints(min_length=1, max_length=64, pattern=r"^[a-f0-9]{8}$")
    ] = Field(
        default="00000000",
        description="Current run identifier — scopes all put() writes; overridden at runtime by SessionIdentity.session_id",
    )
    phase: PhaseId = Field(
        default=PhaseId.compose,
        description="Current phase — scopes put() writes; overridden at runtime by each IO executor",
    )
    docs_dir: Annotated[
        str,
        StringConstraints(
            min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./: @]+$"
        ),
    ] = Field(
        default="store/docs",
        description="Directory for docs and tracker logs — independent of artifact blobs",
    )

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
            db_path = Path(url[len("sqlite:///") :])
            db_path.parent.mkdir(parents=True, exist_ok=True)
        engine = create_engine(url)
        with engine.connect() as conn:
            conn.execute(
                text("""
                CREATE TABLE IF NOT EXISTS artifacts (
                    id            INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id        TEXT NOT NULL,
                    phase         TEXT NOT NULL,
                    artifact_type TEXT NOT NULL,
                    blob_path     TEXT NOT NULL DEFAULT '',
                    metadata_json TEXT NOT NULL DEFAULT '{}',
                    created_at    TEXT NOT NULL,
                    UNIQUE(session_id, phase, artifact_type)
                )
            """)
            )
            conn.execute(
                text(
                    "CREATE INDEX IF NOT EXISTS idx_run_phase ON artifacts(session_id, phase)"
                )
            )
            conn.commit()
        return engine

    def blob_path_for(self, artifact_type: str, ext: str = "pkl") -> Path:
        """Compute the canonical blob path for this run/phase/artifact_type."""
        root = Path(self.blob_dir) / self.session_id
        root.mkdir(parents=True, exist_ok=True)
        return root / f"{self.phase.value}_{artifact_type}.{ext}"

    def put(
        self, artifact_type: str, metadata: BaseModel, blob_path: str = ""
    ) -> IOResult[None, Exception]:
        """Bind: write artifact metadata row to DB. Returns IOResult instead of raising.

        INSERT OR REPLACE so re-runs of the same (session_id, phase, artifact_type)
        update in place rather than accumulating stale rows.
        """
        try:
            from sqlalchemy import text

            engine = self._engine()
            now = datetime.now(timezone.utc).isoformat()
            meta_json = metadata.model_dump_json()
            with engine.connect() as conn:
                conn.execute(
                    text("""
                    INSERT INTO artifacts(session_id, phase, artifact_type, blob_path, metadata_json, created_at)
                    VALUES (:session_id, :phase, :artifact_type, :blob_path, :metadata_json, :created_at)
                    ON CONFLICT(session_id, phase, artifact_type) DO UPDATE SET
                        blob_path     = excluded.blob_path,
                        metadata_json = excluded.metadata_json,
                        created_at    = excluded.created_at
                """),
                    {
                        "session_id": self.session_id,
                        "phase": self.phase.value,
                        "artifact_type": artifact_type,
                        "blob_path": blob_path,
                        "metadata_json": meta_json,
                        "created_at": now,
                    },
                )
                conn.commit()
            return IOSuccess(None)
        except Exception as exc:
            return IOFailure(exc)

    def get(
        self, session_id: str, phase: str, artifact_type: str
    ) -> Maybe[ArtifactRow]:
        """Extract: retrieve artifact row by (session_id, phase, artifact_type). Returns Maybe instead of raising."""
        from sqlalchemy import text

        engine = self._engine()
        with engine.connect() as conn:
            row = conn.execute(
                text("""
                SELECT session_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                WHERE session_id = :session_id AND phase = :phase AND artifact_type = :artifact_type
            """),
                {
                    "session_id": session_id,
                    "phase": phase,
                    "artifact_type": artifact_type,
                },
            ).fetchone()
        if row is None:
            return Nothing
        return Some(_row_to_artifact(row))

    def latest(self, phase: str, artifact_type: str) -> Maybe[ArtifactRow]:
        """Extract: retrieve most recently written artifact for (phase, artifact_type). Returns Maybe instead of raising."""
        from sqlalchemy import text

        engine = self._engine()
        with engine.connect() as conn:
            row = conn.execute(
                text("""
                SELECT session_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                WHERE phase = :phase AND artifact_type = :artifact_type
                ORDER BY created_at DESC LIMIT 1
            """),
                {"phase": phase, "artifact_type": artifact_type},
            ).fetchone()
        if row is None:
            return Nothing
        return Some(_row_to_artifact(row))

    def all_runs(self) -> list[ArtifactRow]:
        """Extract: return all artifact rows ordered by created_at DESC."""
        from sqlalchemy import text

        engine = self._engine()
        with engine.connect() as conn:
            rows = conn.execute(
                text("""
                SELECT session_id, phase, artifact_type, blob_path, metadata_json, created_at
                FROM artifacts
                ORDER BY created_at DESC
            """)
            ).fetchall()
        return [_row_to_artifact(r) for r in rows]
