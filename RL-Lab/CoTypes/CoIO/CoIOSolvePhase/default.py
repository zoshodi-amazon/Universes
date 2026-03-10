"""CoIOSolvePhase [CoIO] — Train phase observation executor.

Coalgebraic observer: probes the last train artifact from StoreMonad,
checks it against CoSolveHom specification, populates CoSolveProductOutput.
"""

import json
import math
import uuid
from datetime import datetime, timezone
from pathlib import Path

from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from CoTypes.CoHom.Solve.default import CoSolveHom
from CoTypes.CoProduct.Solve.Output.default import CoSolveProductOutput
from CoTypes.CoProduct.Solve.Meta.default import CoSolveProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoSolveHom, store: StoreMonad) -> CoSolveProductOutput:
    """Observe the last train artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoSolveProductMeta(
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

    model_present = False
    normalize_present = False
    reward_finite = False

    # Probe StoreMonad for the latest train (model) artifact
    try:
        row = store.latest(PhaseId.solve.value, "model")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        # Check model blob presence on disk
        if row.blob_path and Path(row.blob_path).exists():
            model_present = True

        # Check normalize artifact
        try:
            norm_row = store.latest(PhaseId.solve.value, "normalize")
            if norm_row.blob_path and Path(norm_row.blob_path).exists():
                normalize_present = True
        except KeyError:
            normalize_present = False

        # Check reward finiteness from metadata
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            final_reward = md.get("final_reward")
            if isinstance(final_reward, (int, float)) and math.isfinite(final_reward):
                reward_finite = True
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    return CoSolveProductOutput(
        observer_id=observer_id,
        model_present=model_present,
        normalize_present=normalize_present,
        reward_finite=reward_finite,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOSolvePhase Settings — Train observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOSolvePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-solve",
    )
    solve: CoSolveHom = Field(
        default_factory=CoSolveHom,
        description="Train observer config",
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
    result = run(s.solve, s.store)
    print(result.model_dump_json(indent=2))
