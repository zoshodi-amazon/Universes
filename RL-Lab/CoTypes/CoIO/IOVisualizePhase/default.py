"""IOVisualizePhase [QGP-dual] — Rerun multi-modal artifact observer for RL pipeline outputs.

Covariant presheaf executor: queries StoreMonad.all_runs() for all ArtifactRow entries
and logs scalar series, text, and optionally feature DataFrames to Rerun without
participating in the phase chain.

extract : StoreMonad.all_runs() → ScalarSeriesSet → RenderScene
extend  : (TraceComonad → str) → IOVisualizePhase → IOVisualizePhase

Usage:
    # Standard (web viewer, no features):
    just visualize

    # With feature DataFrame geometry:
    just visualize --visualize.include_features true

    # Custom DB URL:
    just visualize --visualize.db_url sqlite:///path/to/.rl.db

    # Force a specific Rerun recording ID:
    just visualize --visualize.recording_id my_run_001

Serves Rerun web viewer at http://localhost:9090 by default (tmux-compatible).
Stops cleanly on SIGINT (Ctrl-C).
"""

import json
import signal
import sys
import uuid
from datetime import datetime, timezone
from types import FrameType

from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from CoTypes.CoHom.Visualize.default import VisualizeCoHom
from CoTypes.CoProduct.Visualize.Output.default import VisualizeCoProductOutput
from CoTypes.CoProduct.Visualize.Meta.default import VisualizeCoProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId

_SHUTDOWN = False


def _handle_signal(signum: int, frame: FrameType | None) -> None:
    global _SHUTDOWN
    _SHUTDOWN = True


# ---------------------------------------------------------------------------
# Artifact schemas — minimal typed wrappers to parse ProductOutput JSON blobs.
# We load by duck-typing the JSON rather than importing the full Types/ tree
# to keep CoTypes coalgebraic: observers only destructure, never construct.
# ---------------------------------------------------------------------------


def _get(d: dict, *keys: str, default=None):
    """Safe nested get for JSON blobs."""
    cur = d
    for k in keys:
        if not isinstance(cur, dict):
            return default
        cur = cur.get(k, default)
        if cur is None:
            return default
    return cur


def run(cfg: VisualizeCoHom) -> VisualizeCoProductOutput:
    """extract: query StoreMonad for all artifact rows, log all scalars and text to Rerun."""
    try:
        import rerun as rr
    except ImportError:
        print(
            "[visualize] rerun-sdk not installed — run: uv add rerun-sdk",
            file=sys.stderr,
        )
        sys.exit(1)

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    observer_id = uuid.uuid4().hex[:8]
    meta = VisualizeCoProductMeta(trace=TraceComonad(observer_id=observer_id))

    # Build a read-only StoreMonad pointed at the configured DB
    store = StoreMonad(
        db_url=cfg.db_url,
        blob_dir="store/blobs",
        run_id="00000000",
        phase=PhaseId.pipeline,
    )

    try:
        rows = store.all_runs()
    except Exception as e:
        print(f"[visualize] failed to query store: {e}", file=sys.stderr)
        meta.trace.connection_ok = False
        return VisualizeCoProductOutput(observer_id=observer_id, meta=meta)

    if not rows:
        print("[visualize] no artifacts found in store", file=sys.stderr)
        meta.trace.connection_ok = True
        return VisualizeCoProductOutput(observer_id=observer_id, meta=meta)

    # Determine recording_id
    recording_id = cfg.recording_id if cfg.recording_id else f"rl-{observer_id}"

    rr.init(recording_id, spawn=cfg.spawn_viewer)

    if cfg.serve_web:
        rr.serve_web(open_browser=False)
        viewer_url = "http://localhost:9090"
        print(f"[visualize] Rerun web viewer: {viewer_url}", flush=True)
    else:
        viewer_url = ""

    n_series = 0
    n_errors = 0
    run_ids: set[str] = set()
    phases: set[str] = set()
    feature_columns_logged = 0

    for row in rows:
        if _SHUTDOWN:
            break

        phase = row.phase
        run_id = row.run_id
        artifact_type = row.artifact_type

        run_ids.add(run_id)
        phases.add(phase)
        meta.trace.cursor = f"{phase}/{run_id}/{artifact_type}"
        meta.trace.events_seen += 1
        meta.trace.last_seen_at = datetime.now(timezone.utc).isoformat()

        try:
            data = json.loads(row.metadata_json)
        except Exception:
            continue

        ns = f"/pipeline/{run_id}/{phase}"

        # ---------------------------------------------------------------
        # Phase-specific scalar extraction
        # ---------------------------------------------------------------
        if phase == "discovery":
            qualifying_count = len(_get(data, "qualifying_tickers", default=[]))
            top_adx = _get(data, "meta", "top_adx_score", default=-1.0)
            rr.log(f"{ns}/qualifying_count", rr.Scalar(qualifying_count))
            rr.log(f"{ns}/top_adx_score", rr.Scalar(top_adx))
            n_series += 2

        elif phase == "ingest":
            n_bars = _get(data, "n_bars", default=0)
            rr.log(f"{ns}/n_bars", rr.Scalar(n_bars))
            n_series += 1

        elif phase == "feature":
            n_static = _get(data, "n_static_features", default=0)
            n_valid = _get(data, "n_valid_bars", default=0)
            rr.log(f"{ns}/n_static_features", rr.Scalar(n_static))
            rr.log(f"{ns}/n_valid_bars", rr.Scalar(n_valid))
            n_series += 2

            if cfg.include_features:
                feature_names = _get(data, "feature_names", default=[])
                for col in feature_names:
                    rr.log(f"{ns}/features/{col}", rr.TextLog(col))
                    feature_columns_logged += 1
                    n_series += 1

        elif phase == "train":
            final_reward = _get(data, "final_reward", default=0.0)
            total_ts = _get(data, "total_timesteps", default=0)
            rr.log(f"{ns}/final_reward", rr.Scalar(final_reward))
            rr.log(f"{ns}/total_timesteps", rr.Scalar(total_ts))
            n_series += 2

        elif phase == "eval":
            ret = _get(data, "portfolio_return_pct", default=0.0)
            drawdown = _get(data, "meta", "max_drawdown_pct", default=0.0)
            window = _get(data, "window_index", default=0)
            rr.log(f"{ns}/{window}/portfolio_return_pct", rr.Scalar(ret))
            rr.log(f"{ns}/{window}/max_drawdown_pct", rr.Scalar(drawdown))
            n_series += 2

        elif phase == "serve":
            ret = _get(data, "portfolio_return_pct", default=0.0)
            n_bars = _get(data, "n_bars_served", default=0)
            rr.log(f"{ns}/portfolio_return_pct", rr.Scalar(ret))
            rr.log(f"{ns}/n_bars_served", rr.Scalar(n_bars))
            n_series += 2

        elif phase in ("pipeline", "main"):
            win_rate = _get(data, "win_rate_pct", default=0.0)
            duration = _get(data, "duration_s", default=0.0)
            rr.log(f"{ns}/win_rate_pct", rr.Scalar(win_rate))
            rr.log(f"{ns}/duration_s", rr.Scalar(duration))
            n_series += 2

        # ---------------------------------------------------------------
        # Phase timing (from ObservabilityMonad inside meta.obs)
        # ---------------------------------------------------------------
        timing = _get(data, "meta", "obs", "timing", default={})
        for phase_key, duration_s in timing.items():
            rr.log(
                f"/pipeline/{run_id}/timing/{phase_key}/duration_s",
                rr.Scalar(float(duration_s)),
            )
            n_series += 1

        # ---------------------------------------------------------------
        # Errors (from ObservabilityMonad inside meta.obs.errors list)
        # ---------------------------------------------------------------
        errors = _get(data, "meta", "obs", "errors", default=[])
        for i, err in enumerate(errors):
            msg = _get(err, "message", default=str(err))
            rr.log(
                f"/pipeline/{run_id}/errors/{phase}/{i}/message",
                rr.TextLog(msg, level=rr.TextLogLevel.ERROR),
            )
            n_errors += 1
            n_series += 1

        if cfg.serve_web:
            print(f"[visualize] logged {phase}/{run_id}/{artifact_type}", flush=True)

    meta.trace.connection_ok = True
    meta.run_ids_found = sorted(run_ids)
    meta.phases_found = sorted(phases)
    meta.feature_columns_logged = feature_columns_logged

    # If serving web, keep process alive until SIGINT
    if cfg.serve_web and not _SHUTDOWN:
        import time

        print("[visualize] serving — press Ctrl-C to stop", flush=True)
        while not _SHUTDOWN:
            time.sleep(0.5)

    return VisualizeCoProductOutput(
        observer_id=observer_id,
        n_phases_logged=len(phases),
        n_series_logged=n_series,
        n_errors_logged=n_errors,
        io_rrd_path="",
        viewer_url=viewer_url,
        meta=meta,
    )


class Settings(BaseSettings):
    """IOVisualizePhase Settings [QGP-dual] — Rerun multi-modal artifact observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/IOVisualizePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-visualize",
    )
    visualize: VisualizeCoHom = Field(
        default_factory=VisualizeCoHom,
        description="Visualize observer config — db_url, recording_id, spawn_viewer, serve_web, include_features",
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
    run(s.visualize)
