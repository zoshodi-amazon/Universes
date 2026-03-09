"""CoIOMainPhase [CoIO] — Main phase observation executor.

Coalgebraic observer: probes the last main pipeline artifact from StoreMonad,
checks it against CoMainHom specification, populates CoMainProductOutput.
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

from CoTypes.CoHom.Main.default import CoMainHom
from CoTypes.CoProduct.Main.Output.default import CoMainProductOutput
from CoTypes.CoProduct.Main.Meta.default import CoMainProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoMainHom, store: StoreMonad) -> CoMainProductOutput:
    """Observe the last main pipeline artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoMainProductMeta(
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

    pipeline_completed = False
    windows_evaluated = False
    result_persisted = False

    # Probe StoreMonad for the latest main artifact
    try:
        row = store.latest(PhaseId.pipeline.value, "main")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        pipeline_completed = True
        result_persisted = True

        # Check metadata for window evaluation
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            n_windows = md.get("n_windows", 0)
            windows_evaluated = isinstance(n_windows, (int, float)) and n_windows > 0
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    return CoMainProductOutput(
        observer_id=observer_id,
        pipeline_completed=pipeline_completed,
        windows_evaluated=windows_evaluated,
        result_persisted=result_persisted,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOMainPhase Settings — Main observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOMainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-main",
    )
    main: CoMainHom = Field(
        default_factory=CoMainHom,
        description="Main observer config",
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
    result = run(s.main, s.store)
    print(result.model_dump_json(indent=2))
