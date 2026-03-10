"""IOIngestPhase [QGP] — IngestHom + IndexIdentity -> IngestProductOutput.

Downloads OHLCV, caches under store/blobs/cache/, trims warmup.
Returns IngestProductOutput. Blob written to store via StoreMonad.put().
"""

from pathlib import Path
from datetime import datetime, timezone
import pandas as pd
import yfinance as yf
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Hom.Ingest.default import IngestHom
from Types.Identity.Index.default import IndexIdentity
from Types.Identity.Session.default import SessionIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Product.Ingest.Meta.default import IngestProductMeta
from Types.Product.Ingest.Output.default import IngestProductOutput
from Types.Inductive.Frame.default import FrameInductive
from Types.Monad.Store.default import StoreMonad
from returns.io import IOFailure

INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}
PERIOD_MULTIPLIER = {"stock": 7 / 5, "forex": 7 / 5, "crypto": 1.0}


def _normalize_period(period: str, index_class: str) -> str:
    days = int(period.rstrip("d"))
    cal_days = int(days * PERIOD_MULTIPLIER[index_class])
    return f"{cal_days}d"


def run(
    specs: IngestHom,
    asset: IndexIdentity,
    run_base: SessionIdentity,
    store_base: StoreMonad,
) -> IngestProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = IngestProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.ingest

    store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": PhaseId.ingest}
    )
    cache_dir = Path(store.blob_dir) / "cache"
    cache_dir.mkdir(parents=True, exist_ok=True)

    yf_interval = INTERVAL_MAP[asset.interval_min]
    yf_period = _normalize_period(specs.period, asset.index_class.value)
    raw_path = cache_dir / f"{asset.io_ticker}_{yf_interval}_raw.pkl"

    df = pd.DataFrame()

    if raw_path.exists():
        try:
            raw_df = pd.read_pickle(raw_path)
            validated = FrameInductive.from_dataframe(raw_df)
            df = validated.to_dataframe(index=raw_df.index)
            meta.cache_hit = True
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.ingest,
                    message=f"cache read failed: {str(e)[:128]}",
                    severity=Severity.warn,
                )
            )
            raw_path.unlink()
            df = pd.DataFrame()

    if not raw_path.exists() or len(df) == 0:
        try:
            meta.api_calls += 1
            raw_result = yf.download(
                asset.io_ticker,
                period=yf_period,
                interval=yf_interval,
                auto_adjust=True,
            )
            if raw_result is not None and len(raw_result) > 0:
                validated = FrameInductive.from_dataframe(raw_result)
                df = validated.to_dataframe(index=raw_result.index)
                if isinstance(df.columns, pd.MultiIndex):
                    df.columns = df.columns.get_level_values(0)
                if len(df) > 0:
                    df.to_pickle(str(raw_path))
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.ingest,
                    message=f"yfinance download failed: {str(e)[:128]}",
                    severity=Severity.error,
                )
            )

    if len(df) == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.ingest,
                message=f"no data for {asset.io_ticker} at {yf_interval}",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        raise ValueError(f"no data for {asset.io_ticker} at {yf_interval}")

    meta.raw_bar_count = len(df)
    df.columns = [c.lower() for c in df.columns]
    df.sort_index(inplace=True)
    df.drop_duplicates(inplace=True)

    if len(df) > 1:
        time_diffs = df.index.to_series().diff().dropna()
        expected_gap = pd.Timedelta(minutes=asset.interval_min)
        gap_mask = time_diffs > expected_gap * 2
        meta.data_gaps_count = int(gap_mask.sum())
        if meta.data_gaps_count > 0:
            # Forward-fill small gaps (up to 5x expected interval), warn on larger ones
            max_ffill = expected_gap * 5
            large_gaps = int((time_diffs > max_ffill).sum())
            df = df.ffill()
            if large_gaps > 0:
                meta.obs.errors.append(
                    ErrorMonad(
                        phase=PhaseId.ingest,
                        message=f"{large_gaps} gaps exceed 5x interval ({asset.interval_min}min) — forward-filled",
                        severity=Severity.warn,
                    )
                )

    meta.warmup_trimmed = min(specs.warmup_frames, len(df) - 1)
    df = df.iloc[specs.warmup_frames :]
    df = df.reset_index(drop=False)
    df = df.set_index(df.columns[0])

    blob_path = store.blob_path_for("ingest", ext="pkl")
    try:
        df.to_pickle(str(blob_path))
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.ingest,
                message=f"blob write failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    record = IngestProductOutput(
        session_id=run_base.session_id,
        io_ticker=asset.io_ticker,
        interval_min=asset.interval_min,
        n_bars=len(df),
        meta=meta,
    )

    result = store.put("ingest", record, blob_path=str(blob_path))
    if isinstance(result, IOFailure):
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.ingest,
                message=f"store.put failed: {str(result.failure())[:128]}",
                severity=Severity.error,
            )
        )

    return record


class Settings(BaseSettings):
    """IOIngestPhase Settings [Plasma] — Standalone entrypoint for data ingestion."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOIngestPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="cata-ingest",
    )
    asset: IndexIdentity = Field(
        ..., description="Asset index — ticker, interval, trade hours, holidays"
    )
    run: SessionIdentity = Field(
        default=SessionIdentity(), description="Run context — ID, seed, store"
    )
    store: StoreMonad = Field(
        default_factory=StoreMonad, description="Artifact store — DB + blob dir"
    )
    ingest: IngestHom = Field(
        default=IngestHom(), description="Ingest config — lookback period, warmup"
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
    run(s.ingest, s.asset, s.run, s.store)
