"""IODiscoveryPhase [Plasma] — standalone: screener + ADX filter.

Own BaseSettings + default.json. No cross-phase imports for settings.
"""
from pathlib import Path
from datetime import datetime, timezone
import uuid
import pandas as pd
import yfinance as yf
import pandas_ta as ta
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.DiscoveryInput.default import DiscoveryInput
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.DiscoveryOutput.default import DiscoveryOutput

INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}


class Settings(BaseSettings):
    """IODiscoveryPhase Settings [Plasma] — Composes asset, run, and discovery config for screener phase."""
    model_config = SettingsConfigDict(
        json_file="Monads/IODiscoveryPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="discover",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    discovery: DiscoveryInput = Field(default=DiscoveryInput(io_universe=[]), description="Discovery config — screener, ADX threshold, universe")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


def _fetch_universe(screener: str) -> list[str]:
    try:
        resp = yf.screen(screener)
        quotes = resp.get("quotes", [])
        return [q["symbol"] for q in quotes if "symbol" in q]
    except Exception:
        return []


def run(settings: Settings) -> DiscoveryOutput:
    specs = settings.discovery
    asset = settings.asset
    run_id = settings.run.run_id
    run_ts = settings.run.run_ts
    output_dir = settings.run.output_dir

    cache_dir = Path(specs.cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)
    yf_interval = INTERVAL_MAP[asset.interval_min]

    universe = list(specs.io_universe) if specs.io_universe else _fetch_universe(specs.screener)

    adx_scores: list[tuple[str, float]] = []
    for ticker in universe:
        cache_path = cache_dir / f"{ticker}_{yf_interval}_raw.pkl"
        if cache_path.exists():
            df = pd.read_pickle(cache_path)
        else:
            try:
                df = yf.download(ticker, period=specs.period, interval=yf_interval, auto_adjust=True)
                if isinstance(df.columns, pd.MultiIndex):
                    df.columns = df.columns.get_level_values(0)
                df.to_pickle(str(cache_path))
            except Exception:
                continue

        df.columns = [c.lower() for c in df.columns]
        if len(df) < specs.min_bars:
            continue

        adx_df = ta.adx(df["high"], df["low"], df["close"], length=14)
        if adx_df is None:
            continue
        adx_col = [c for c in adx_df.columns if c.startswith("ADX_")][0]
        latest_adx = adx_df[adx_col].iloc[-1]
        if pd.notna(latest_adx) and latest_adx >= specs.min_adx:
            adx_scores.append((ticker, float(latest_adx)))

    adx_scores.sort(key=lambda x: x[1], reverse=True)
    qualifying = [t for t, _ in adx_scores]

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    data_path = out / f"discovery_{run_ts}_{run_id}.json"

    record = DiscoveryOutput(
        run_id=run_id,
        universe_size=max(len(universe), 1),
        qualifying_tickers=qualifying,
        min_adx_used=specs.min_adx,
        io_scan_date=datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        n_qualifying=len(qualifying),
        io_data_path=str(data_path),
    )
    data_path.write_text(record.model_dump_json(indent=2))
    return record


if __name__ == "__main__":
    run(Settings())
