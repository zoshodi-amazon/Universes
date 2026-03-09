"""CoIOEvalPhase [CoIO] — Eval phase observation executor.

Coalgebraic observer: probes the last eval artifact from StoreMonad,
checks it against CoEvalHom specification, populates CoEvalProductOutput.
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

from CoTypes.CoHom.Eval.default import CoEvalHom
from CoTypes.CoProduct.Eval.Output.default import CoEvalProductOutput
from CoTypes.CoProduct.Eval.Meta.default import CoEvalProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


def run(cfg: CoEvalHom, store: StoreMonad) -> CoEvalProductOutput:
    """Observe the last eval artifact and populate observation result."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoEvalProductMeta(
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

    eval_completed = False
    return_recorded = False
    render_logs_present = False

    # Probe StoreMonad for the latest eval artifact
    try:
        row = store.latest(PhaseId.eval.value, "eval")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    # Populate observation checks
    if meta.artifact_found:
        eval_completed = True

        # Check return was recorded in metadata
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            portfolio_return = md.get("portfolio_return_pct")
            return_recorded = portfolio_return is not None
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

        # Check render logs path
        try:
            render_dir = Path(store.blob_dir) / store.run_id
            if render_dir.exists():
                log_files = list(render_dir.glob("eval_render*"))
                render_logs_present = len(log_files) > 0
        except (OSError, ValueError):
            render_logs_present = False

    return CoEvalProductOutput(
        observer_id=observer_id,
        eval_completed=eval_completed,
        return_recorded=return_recorded,
        render_logs_present=render_logs_present,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOEvalPhase Settings — Eval observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOEvalPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-eval",
    )
    eval: CoEvalHom = Field(
        default_factory=CoEvalHom,
        description="Eval observer config",
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
    result = run(s.eval, s.store)
    print(result.model_dump_json(indent=2))
