"""IOTailPhase [QGP-dual] — Blocking SSE event stream observer for OpenCode.

Covariant presheaf executor: observes the OpenCode SSE event bus without
participating in the phase chain.

extract : SSEStream → FilteredEventSequence
extend  : (TraceComonad → str) → IOTailPhase → IOTailPhase

Usage:
    # Start OpenCode with pinned port in one tmux pane:
    opencode --port 4096

    # In a second pane:
    just tail
    just tail --tail.port 4096 --tail.filter_kinds '["tool","file"]'

Stops cleanly on SIGINT (Ctrl-C).
"""

import json
import signal
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path
from types import FrameType

from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from CoTypes.CoHom.Tail.default import TailCoHom
from CoTypes.CoProduct.Tail.Output.default import TailCoProductOutput
from CoTypes.CoProduct.Tail.Meta.default import TailCoProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId

_SHUTDOWN = False


def _handle_signal(signum: int, frame: FrameType | None) -> None:
    global _SHUTDOWN
    _SHUTDOWN = True


def run(cfg: TailCoHom) -> TailCoProductOutput:
    """extract: pull SSE events from OpenCode stream, filter by kind, display."""
    import urllib.request
    import urllib.error

    observer_id = uuid.uuid4().hex[:8]
    server_url = f"http://{cfg.hostname}:{cfg.port}/v1/events"
    meta = TailCoProductMeta(trace=TraceComonad(observer_id=observer_id))
    events_received = 0
    events_displayed = 0

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    def _matches_filter(kind: str) -> bool:
        return any(kind.startswith(prefix) for prefix in cfg.filter_kinds)

    def _fmt_event(kind: str, data: dict) -> str:
        ts = datetime.now(timezone.utc).strftime("%H:%M:%S")
        payload = json.dumps(data, ensure_ascii=False)
        if len(payload) > 200:
            payload = payload[:200] + "…"
        return f"[{ts}] {kind}  {payload}"

    while not _SHUTDOWN:
        req = urllib.request.Request(
            server_url, headers={"Accept": "text/event-stream"}
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                meta.trace.connection_ok = True
                buf = ""
                while not _SHUTDOWN:
                    chunk = resp.read(1)
                    if not chunk:
                        break
                    buf += chunk.decode("utf-8", errors="replace")
                    if "\n\n" not in buf:
                        continue
                    raw, buf = buf.split("\n\n", 1)
                    event_kind = ""
                    event_data: dict = {}
                    for line in raw.splitlines():
                        if line.startswith("event:"):
                            event_kind = line[6:].strip()
                        elif line.startswith("data:"):
                            try:
                                event_data = json.loads(line[5:].strip())
                            except Exception:
                                event_data = {"raw": line[5:].strip()}
                    if not event_kind:
                        continue
                    events_received += 1
                    meta.trace.events_seen = events_received
                    meta.trace.cursor = event_kind
                    meta.trace.last_seen_at = datetime.now(timezone.utc).isoformat()
                    if _matches_filter(event_kind):
                        print(_fmt_event(event_kind, event_data), flush=True)
                        events_displayed += 1
                    else:
                        meta.filter_misses += 1

        except urllib.error.URLError as e:
            meta.trace.connection_ok = False
            meta.connection_failures += 1
            if not _SHUTDOWN:
                print(
                    f"[tail] connection failed: {e} — retrying in 2s",
                    file=sys.stderr,
                    flush=True,
                )
                import time

                time.sleep(2)
        except Exception as e:
            meta.trace.connection_ok = False
            meta.connection_failures += 1
            if not _SHUTDOWN:
                print(
                    f"[tail] error: {e} — retrying in 2s", file=sys.stderr, flush=True
                )
                import time

                time.sleep(2)

    return TailCoProductOutput(
        observer_id=observer_id,
        events_received=events_received,
        events_displayed=events_displayed,
        server_url=server_url,
        meta=meta,
    )


class Settings(BaseSettings):
    """IOTailPhase Settings [QGP-dual] — SSE event stream observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/IOTailPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-tail",
    )
    tail: TailCoHom = Field(
        default_factory=TailCoHom,
        description="Tail observer config — port, hostname, filter_kinds",
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
    run(s.tail)
