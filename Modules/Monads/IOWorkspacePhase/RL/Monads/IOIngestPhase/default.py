"""IOIngestPhase [Plasma] — IngestInput + AssetUnit -> IngestOutput.

Downloads OHLCV, caches, trims warmup. Returns IngestOutput only. No print.
Period normalization: stock/forex trade ~5/7 calendar days, crypto trades 24/7.
"""
from pathlib import Path
import pandas as pd
import yfinance as yf
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.IngestOutput.default import IngestOutput

INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}

PERIOD_MULTIPLIER = {"stock": 7 / 5, "forex": 7 / 5, "crypto": 1.0}


def _normalize_period(period: str, asset_type: str) -> str:
    days = int(period.rstrip("d"))
    cal_days = int(days * PERIOD_MULTIPLIER[asset_type])
    return f"{cal_days}d"


def run(specs: IngestInput, asset: AssetUnit, run_base: RunUnit) -> IngestOutput:
    cache_dir = Path(specs.cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)
    yf_interval = INTERVAL_MAP[asset.interval_min]
    yf_period = _normalize_period(specs.period, asset.asset_type.value)
    raw_path = cache_dir / f"{asset.io_ticker}_{yf_interval}_raw.pkl"

    if raw_path.exists():
        try:
            df = pd.read_pickle(raw_path)
        except Exception:
            raw_path.unlink()
            df = pd.DataFrame()

    if not raw_path.exists():
        df = yf.download(
            asset.io_ticker, period=yf_period,
            interval=yf_interval, auto_adjust=True,
        )
        if isinstance(df.columns, pd.MultiIndex):
            df.columns = df.columns.get_level_values(0)
        if len(df) > 0:
            df.to_pickle(str(raw_path))

    if len(df) == 0:
        raise ValueError(f"no data for {asset.io_ticker} at {yf_interval}")

    df.columns = [c.lower() for c in df.columns]
    df.sort_index(inplace=True)
    df.drop_duplicates(inplace=True)

    df = df.iloc[specs.warmup_bars:]
    df = df.reset_index(drop=False)
    df = df.set_index(df.columns[0])

    out = Path(run_base.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    data_path = out / f"ingest_{run_base.run_ts}_{run_base.run_id}.pkl"
    df.to_pickle(str(data_path))

    return IngestOutput(
        run_id=run_base.run_id,
        io_ticker=asset.io_ticker,
        interval_min=asset.interval_min,
        n_bars=len(df),
        io_start_date=str(df.index[0]),
        io_end_date=str(df.index[-1]),
        io_data_path=str(data_path),
    )


class Settings(BaseSettings):
    """IOIngestPhase Settings [Plasma] — Standalone entrypoint for data ingestion."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOIngestPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ingest",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    ingest: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    run(s.ingest, s.asset, s.run)
