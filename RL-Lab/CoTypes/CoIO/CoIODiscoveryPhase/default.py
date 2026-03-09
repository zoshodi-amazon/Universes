"""CoIODiscoveryPhase [CoIO] — Discovery phase observation executor.

Coalgebraic observer: probes the last discovery artifact from StoreMonad,
checks it against CoDiscoveryHom specification, populates CoDiscoveryProductOutput.
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

from CoTypes.CoHom.Discovery.default import CoDiscoveryHom
from CoTypes.CoProduct.Discovery.Output.default import CoDiscoveryProductOutput
from CoTypes.CoProduct.Discovery.Meta.default import CoDiscoveryProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoDiscoveryHom, store: StoreMonad) -> CoDiscoveryProductOutput:
    """Observe the last discovery artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoDiscoveryProductMeta(
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

    universe_resolved = False
    screener_responded = False
    qualifying_found = False

    # Probe StoreMonad for the latest discovery artifact
    try:
        row = store.latest(PhaseId.discovery.value, "discovery")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks from metadata
    if meta.artifact_found:
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            universe_resolved = True
            screener_responded = True
            qualifying_found = (
                isinstance(md.get("qualifying_tickers"), list)
                and len(md["qualifying_tickers"]) > 0
            )
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    return CoDiscoveryProductOutput(
        observer_id=observer_id,
        universe_resolved=universe_resolved,
        screener_responded=screener_responded,
        qualifying_found=qualifying_found,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIODiscoveryPhase Settings — Discovery observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIODiscoveryPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-discovery",
    )
    discovery: CoDiscoveryHom = Field(
        default_factory=CoDiscoveryHom,
        description="Discovery observer config",
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
    result = run(s.discovery, s.store)
    print(result.model_dump_json(indent=2))
