from pydantic import BaseModel, Field


class StoreMonad(BaseModel):
    """[Monad] — Artifact store effect type, Plasma phase. SQLite + blob filesystem."""

    db_url: str = Field(
        default="sqlite:///store/.materiallab.db",
        min_length=1,
        max_length=256,
        description="SQLite database URL",
    )
    blob_dir: str = Field(
        default="store/blobs",
        min_length=1,
        max_length=256,
        description="Filesystem directory for blob artifacts",
    )
    run_id: str = Field(
        default="00000000",
        min_length=8,
        max_length=8,
        description="Current run_id (sentinel '00000000' = not set)",
    )
    phase: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="Current phase name (sentinel '' = not set)",
    )
    docs_dir: str = Field(
        default="store/docs",
        min_length=1,
        max_length=256,
        description="Filesystem directory for documentation artifacts",
    )
