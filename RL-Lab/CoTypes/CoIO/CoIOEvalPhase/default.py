"""CoIOEvalPhase [CoIO] — Eval phase observation executor.

Coalgebraic observer: probes the last eval artifact from StoreMonad,
checks it against CoEvalHom specification, populates CoEvalProductOutput.
Optionally launches gym-trading-env Flask render dashboard (absorbed from ana-render).
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
    maybe_row = store.latest(PhaseId.eval.value, "eval")
    if isinstance(maybe_row, Some):
        row = maybe_row.unwrap()
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
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
        render_dir = Path(store.blob_dir) / store.session_id / "render_logs"
        try:
            if render_dir.exists():
                log_files = list(render_dir.glob("*"))
                render_logs_present = len(log_files) > 0
            else:
                # Also check for eval_render* pattern in run dir
                run_dir = Path(store.blob_dir) / store.session_id
                if run_dir.exists():
                    log_files = list(run_dir.glob("eval_render*"))
                    render_logs_present = len(log_files) > 0
        except (OSError, ValueError):
            render_logs_present = False

    # Launch Flask render dashboard if requested and logs are present
    if cfg.launch_renderer and render_logs_present:
        render_dir = Path(store.blob_dir) / store.session_id / "render_logs"
        if render_dir.exists():
            from gym_trading_env.renderer import Renderer

            renderer = Renderer(dir=str(render_dir))
            renderer.run()

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
        from pathlib import Path as _P

        sources = [CliSettingsSource(settings_cls, cli_parse_args=True)]
        _local = _P(__file__).parent / "local.json"
        if _local.exists():
            sources.append(JsonConfigSettingsSource(settings_cls, json_file=_local))
        sources.append(JsonConfigSettingsSource(settings_cls))
        return tuple(sources)


if __name__ == "__main__":
    s = Settings()
    result = run(s.eval, s.store)
    print(result.model_dump_json(indent=2))
