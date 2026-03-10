"""CoIOServePhase [CoIO] — Serve phase observation executor.

Coalgebraic observer: probes the last serve artifact from StoreMonad,
checks it against CoServeHom specification, populates CoServeProductOutput.
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

from CoTypes.CoHom.Serve.default import CoServeHom
from CoTypes.CoProduct.Serve.Output.default import CoServeProductOutput
from CoTypes.CoProduct.Serve.Meta.default import CoServeProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoServeHom, store: StoreMonad) -> CoServeProductOutput:
    """Observe the last serve artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoServeProductMeta(
        trace=TraceComonad(
            observer_id=observer_id,
            cursor="",
            events_seen=0,
            connection_ok=True,
            last_seen_at=now,
        ),
        artifact_found=False,
        schema_valid=False,
    )

    audit_present = False
    orders_logged = False
    shutdown_clean = False

    # Probe StoreMonad for the latest serve artifact
    try:
        row = store.latest(PhaseId.serve.value, "serve")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        # Check audit directory for JSONL files
        try:
            audit_dir = Path(store.blob_dir) / store.run_id
            if audit_dir.exists():
                audit_files = list(audit_dir.glob("serve_audit*"))
                audit_present = len(audit_files) > 0
        except (OSError, ValueError):
            audit_present = False

        # Check metadata for orders and shutdown status
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            orders_logged = bool(md.get("orders_logged", False))
            shutdown_clean = bool(md.get("shutdown_clean", False))
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    return CoServeProductOutput(
        observer_id=observer_id,
        audit_present=audit_present,
        orders_logged=orders_logged,
        shutdown_clean=shutdown_clean,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOServePhase Settings — Serve observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOServePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-serve",
    )
    serve: CoServeHom = Field(
        default_factory=CoServeHom,
        description="Serve observer config",
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
    result = run(s.serve, s.store)
    print(result.model_dump_json(indent=2))
