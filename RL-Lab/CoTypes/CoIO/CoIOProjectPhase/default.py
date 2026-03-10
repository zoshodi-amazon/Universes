"""CoIOProjectPhase [CoIO] — Serve phase observation executor.

Coalgebraic observer: probes the last serve artifact from StoreMonad,
checks it against CoProjectHom specification, populates CoProjectProductOutput.
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

from CoTypes.CoHom.Project.default import CoProjectHom
from CoTypes.CoProduct.Project.Output.default import CoProjectProductOutput
from CoTypes.CoProduct.Project.Meta.default import CoProjectProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoProjectHom, store: StoreMonad) -> CoProjectProductOutput:
    """Observe the last serve artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoProjectProductMeta(
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
        row = store.latest(PhaseId.project.value, "project")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        # Check audit directory for JSONL files
        try:
            audit_dir = Path(store.blob_dir) / store.session_id
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

    return CoProjectProductOutput(
        observer_id=observer_id,
        audit_present=audit_present,
        orders_logged=orders_logged,
        shutdown_clean=shutdown_clean,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOProjectPhase Settings — Serve observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOProjectPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-project",
    )
    project: CoProjectHom = Field(
        default_factory=CoProjectHom,
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
        from pathlib import Path as _P

        sources = [CliSettingsSource(settings_cls, cli_parse_args=True)]
        _local = _P(__file__).parent / "local.json"
        if _local.exists():
            sources.append(JsonConfigSettingsSource(settings_cls, json_file=_local))
        sources.append(JsonConfigSettingsSource(settings_cls))
        return tuple(sources)


if __name__ == "__main__":
    s = Settings()
    result = run(s.project, s.store)
    print(result.model_dump_json(indent=2))
