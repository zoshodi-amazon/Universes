"""CoIngestHom [CoHom] — Ingest phase observation spec (3 fields). All bounded.

Liquid-dual — observation specification parallel to IngestHom.
"""

from pydantic import BaseModel, Field


class CoIngestHom(BaseModel):
    """CoIngestHom [CoHom] — What to verify about an ingest run (3 fields)."""

    data_downloaded: bool = Field(
        default=True,
        description="Check that OHLCV data was successfully downloaded or cache-hit",
    )
    schema_validated: bool = Field(
        default=True,
        description="Check that downloaded data passed FrameInductive.from_dataframe()",
    )
    blob_persisted: bool = Field(
        default=True, description="Check that the ingest blob was written to StoreMonad"
    )
