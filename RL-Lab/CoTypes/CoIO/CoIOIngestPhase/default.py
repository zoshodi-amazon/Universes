"""CoIOIngestPhase [CoIO] — Ingest phase observation executor.

Coalgebraic observer: probes the last ingest artifact from StoreMonad,
checks it against CoIngestHom specification, populates CoIngestProductOutput.
"""

import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from CoTypes.CoHom.Ingest.default import CoIngestHom
from CoTypes.CoProduct.Ingest.Output.default import CoIngestProductOutput
from CoTypes.CoProduct.Ingest.Meta.default import CoIngestProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoIngestHom, store: StoreMonad) -> CoIngestProductOutput:
    """Observe the last ingest artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoIngestProductMeta(
        trace=TraceComonad(
            observer_id=observer_id,
            cursor="",
            events_seen=0,
            connection_ok=True,
            last_seen_at=now,
        ),
        artifact_found=False,
        blob_readable=False,
    )

    data_present = False
    schema_valid = False
    bars_sufficient = False

    # Probe StoreMonad for the latest ingest artifact
    try:
        row = store.latest(PhaseId.ingest.value, "ingest")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        # Check blob presence on disk
        if row.blob_path and Path(row.blob_path).exists():
            data_present = True
            meta.blob_readable = True

        # Check schema validity via metadata_json
        try:
            md = json.loads(row.metadata_json)
            schema_valid = True
            n_bars = md.get("n_bars", 0)
            bars_sufficient = isinstance(n_bars, (int, float)) and n_bars > 0
        except (json.JSONDecodeError, TypeError):
            schema_valid = False

    return CoIngestProductOutput(
        observer_id=observer_id,
        data_present=data_present,
        schema_valid=schema_valid,
        bars_sufficient=bars_sufficient,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOIngestPhase Settings — Ingest observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOIngestPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-ingest",
    )
    ingest: CoIngestHom = Field(
        default_factory=CoIngestHom,
        description="Ingest observer config",
    )
    store: StoreMonad = Field(
        default_factory=StoreMonad,
        description="Artifact store — DB + blob dir",
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource

        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    result = run(s.ingest, s.store)
    print(result.model_dump_json(indent=2))
