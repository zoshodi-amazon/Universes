"""CoIOTransformPhase [CoIO] — Feature phase observation executor.

Coalgebraic observer: probes the last feature artifact from StoreMonad,
checks it against CoTransformHom specification, populates CoTransformProductOutput.
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

from returns.maybe import Some

from CoTypes.CoHom.Transform.default import CoTransformHom
from CoTypes.CoProduct.Transform.Output.default import CoTransformProductOutput
from CoTypes.CoProduct.Transform.Meta.default import CoTransformProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoTransformHom, store: StoreMonad) -> CoTransformProductOutput:
    """Observe the last feature artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoTransformProductMeta(
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

    features_present = False
    column_count_valid = False
    prefix_enforced = False

    # Probe StoreMonad for the latest feature artifact
    maybe_row = store.latest(PhaseId.transform.value, "features")
    if isinstance(maybe_row, Some):
        row = maybe_row.unwrap()
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path

        # Check blob presence on disk
        if row.blob_path and Path(row.blob_path).exists():
            features_present = True

        # Check metadata for column count and prefix enforcement
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            col_count = md.get("n_feature_columns", 0)
            column_count_valid = isinstance(col_count, (int, float)) and col_count > 0
            prefix_enforced = bool(md.get("prefix_enforced", False))
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    return CoTransformProductOutput(
        observer_id=observer_id,
        features_present=features_present,
        column_count_valid=column_count_valid,
        prefix_enforced=prefix_enforced,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOTransformPhase Settings — Feature observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOTransformPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-transform",
    )
    transform: CoTransformHom = Field(
        default_factory=CoTransformHom,
        description="Feature observer config",
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
    result = run(s.transform, s.store)
    print(result.model_dump_json(indent=2))
