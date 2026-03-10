"""IODiscoveryPhase [QGP] — Phase 1 (BEC): screener + ADX + liquidity filtering.

Own BaseSettings + default.json. No cross-phase imports for settings.
Automatic asset class routing based on IndexIdentity.index_class.
All effectful calls wrapped with typed error handling.
Inductive validation on all yfinance IO boundaries.
"""

from pathlib import Path
from datetime import datetime, timezone
import numpy as np
import pandas as pd
import yfinance as yf
import pandas_ta as ta
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Hom.Discovery.default import DiscoveryHom
from Types.Identity.Index.default import IndexIdentity, IndexClass
from Types.Identity.Session.default import SessionIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Measure.default import MeasureMonad
from Types.Monad.Signal.default import SignalMonad
from Types.Inductive.SeverityInductive.default import SeverityInductive
from Types.Monad.Effect.default import EffectMonad
from Types.Product.Discovery.Output.default import DiscoveryProductOutput
from Types.Product.Discovery.Meta.default import DiscoveryProductMeta
from Types.Inductive.Catalog.default import CatalogInductive
from Types.Inductive.IndexMeta.default import IndexMetaInductive
from Types.Inductive.Frame.default import FrameInductive
from Types.Monad.Store.default import StoreMonad

INTERVAL_MAP: dict[int, str] = {
    1: "1m",
    5: "5m",
    15: "15m",
    30: "30m",
    60: "1h",
    1440: "1d",
}


class Settings(BaseSettings):
    """IODiscoveryPhase Settings [Plasma] — Composes asset, run, and discovery config for screener phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IODiscoveryPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="cata-discover",
    )
    asset: IndexIdentity = Field(
        ..., description="Asset index — ticker, interval, trade hours, holidays"
    )
    run: SessionIdentity = Field(
        default_factory=SessionIdentity, description="Run context — ID, seed, store"
    )
    store: StoreMonad = Field(
        default_factory=StoreMonad, description="Artifact store — DB + blob dir"
    )
    discovery: DiscoveryHom = Field(
        default_factory=lambda: DiscoveryHom(io_indices=[]),
        description="Discovery config — screener, ADX threshold, universe",
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


def _route_by_asset_class(tickers: list[str], index_class: IndexClass) -> list[str]:
    """Filter tickers by asset class. Automatic routing."""
    if index_class == IndexClass.crypto:
        return [t for t in tickers if "-USD" in t or "-USDT" in t or "-USDC" in t]
    elif index_class == IndexClass.forex:
        return [t for t in tickers if "=X" in t]
    else:  # stock
        return [
            t for t in tickers if "-USD" not in t and "=X" not in t and "-USDT" not in t
        ]


def _fetch_universe(catalog_source: str, meta: DiscoveryProductMeta) -> list[str]:
    """Fetch ticker universe from yfinance screener with Inductive validation."""
    try:
        resp = yf.screen(screener)
        validated = CatalogInductive.from_response(resp)
        tickers = validated.get_tickers()
        meta.catalog_source_result_count = len(tickers)
        return tickers
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.discovery,
                message=f"screener fetch failed: {str(e)[:256]}",
                severity=Severity.error,
            )
        )
        return []


def _filter_by_liquidity(
    tickers: list[str],
    specs: DiscoveryHom,
    yf_interval: str,
    meta: DiscoveryProductMeta,
) -> list[str]:
    """Filter tickers by relative liquidity metrics (percentile-based) with Inductive validation."""
    if not specs.liquidity.enabled or len(tickers) == 0:
        return tickers

    if len(tickers) < specs.liquidity.min_universe_size:
        return tickers

    ticker_data: list[tuple[str, float, float, float, float, bool]] = []

    for ticker in tickers:
        try:
            raw_info = yf.Ticker(ticker).info
            info = IndexMetaInductive.from_info(raw_info, symbol=ticker)
            avg_vol: float = info.average_volume if info.average_volume >= 0 else 0.0
            price: float = (
                info.regular_market_price if info.regular_market_price >= 0 else 0.0
            )
            day_high: float = info.day_high if info.day_high >= 0 else price
            day_low: float = info.day_low if info.day_low >= 0 else price
            atr_pct: float = (
                ((day_high - day_low) / price * 100) if price > 0 else 100.0
            )
            mkt_cap: float = info.market_cap if info.market_cap > 0 else 0.0
            turnover_pct: float = (
                (avg_vol * price / mkt_cap * 100) if mkt_cap > 0 else 0.0
            )
            shortable: bool = (
                bool(raw_info.get("shortable", True)) if raw_info else True
            )
            ticker_data.append(
                (ticker, avg_vol, price, atr_pct, turnover_pct, shortable)
            )
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.discovery,
                    message=f"liquidity fetch failed for {ticker}: {str(e)[:64]}",
                    severity=Severity.warn,
                )
            )
            continue

    if len(ticker_data) == 0:
        return []

    volumes: list[float] = [d[1] for d in ticker_data]
    prices: list[float] = [d[2] for d in ticker_data]
    vol_threshold: float = float(
        np.percentile(volumes, 100 - specs.liquidity.min_volume_percentile)
    )
    price_threshold: float = float(
        np.percentile(prices, specs.liquidity.min_price_percentile)
    )

    filtered: list[str] = []
    for ticker, vol, price, atr_pct, turnover_pct, shortable in ticker_data:
        if vol < vol_threshold:
            meta.liquidity_filtered_count += 1
            continue
        if price < price_threshold:
            meta.liquidity_filtered_count += 1
            continue
        if atr_pct > specs.liquidity.max_spread_pct:
            meta.liquidity_filtered_count += 1
            continue
        if turnover_pct < specs.liquidity.min_turnover_pct:
            meta.liquidity_filtered_count += 1
            continue
        if specs.liquidity.require_shortable and not shortable:
            meta.liquidity_filtered_count += 1
            continue
        filtered.append(ticker)

    return filtered


def _evaluate_alarms(
    meta: DiscoveryProductMeta, specs: DiscoveryHom, n_qualifying: int
) -> None:
    """Evaluate alarm thresholds and emit alarms."""
    if not specs.alarms.enabled:
        return

    if n_qualifying < specs.alarms.min_qualifying_tickers:
        meta.obs.alarms.append(
            SignalMonad(
                name="discovery_low_qualifying",
                severity=SeverityInductive.warn
                if n_qualifying > 0
                else SeverityInductive.critical,
                message=f"Only {n_qualifying} tickers qualified (min: {specs.alarms.min_qualifying_tickers})",
                threshold=float(specs.alarms.min_qualifying_tickers),
                actual=float(n_qualifying),
            )
        )

    api_failures: int = len(
        [e for e in meta.obs.errors if "failed" in e.message.lower()]
    )
    if api_failures > specs.alarms.max_api_failures:
        meta.obs.alarms.append(
            SignalMonad(
                name="discovery_api_failures",
                severity=SeverityInductive.critical,
                message=f"{api_failures} API failures exceeded threshold",
                threshold=float(specs.alarms.max_api_failures),
                actual=float(api_failures),
            )
        )


def run(
    specs: DiscoveryHom,
    asset: IndexIdentity,
    run_base: SessionIdentity,
    store_base: StoreMonad,
) -> DiscoveryProductOutput:
    """IODiscoveryPhase entry point with full observability."""
    started: str = datetime.now(timezone.utc).isoformat()
    meta: DiscoveryProductMeta = DiscoveryProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.discovery

    # Cache dir lives under store blobs
    store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": PhaseId.discovery}
    )
    cache_dir: Path = Path(store.blob_dir) / "cache"
    cache_dir.mkdir(parents=True, exist_ok=True)
    yf_interval: str = INTERVAL_MAP[asset.interval_min]

    # Fetch universe
    if specs.io_indices:
        universe: list[str] = list(specs.io_indices)
        meta.catalog_source_result_count = len(universe)
    else:
        universe = _fetch_universe(specs.catalog_source, meta)

    # Asset class routing (automatic)
    pre_route_count: int = len(universe)
    universe = _route_by_asset_class(universe, asset.index_class)
    meta.asset_class_filtered_count = pre_route_count - len(universe)

    # Liquidity filtering (percentile-based)
    universe = _filter_by_liquidity(universe, specs, yf_interval, meta)

    # ADX filtering
    adx_scores: list[tuple[str, float]] = []
    for ticker in universe:
        cache_path: Path = cache_dir / f"{ticker}_{yf_interval}_raw.pkl"
        df: pd.DataFrame | None = None

        try:
            if cache_path.exists():
                df = pd.read_pickle(cache_path)
            else:
                raw_df: pd.DataFrame = yf.download(
                    ticker,
                    period=specs.trend_lookback,
                    interval=yf_interval,
                    auto_adjust=True,
                )
                validated: FrameInductive = FrameInductive.from_dataframe(raw_df)
                df = validated.to_dataframe()
                if df is not None and len(df) > 0:
                    df.to_pickle(str(cache_path))
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.discovery,
                    message=f"download failed for {ticker}: {str(e)[:128]}",
                    severity=Severity.warn,
                )
            )
            continue

        if df is None or len(df) < specs.min_frame_length:
            meta.adx_filtered_count += 1
            continue

        df.columns = [c.lower() for c in df.columns]

        try:
            high_s: pd.Series = pd.Series(df["high"])  # type: ignore[assignment]
            low_s: pd.Series = pd.Series(df["low"])  # type: ignore[assignment]
            close_s: pd.Series = pd.Series(df["close"])  # type: ignore[assignment]
            adx_df: pd.DataFrame | None = ta.adx(high_s, low_s, close_s, length=14)
            if adx_df is None:
                meta.adx_filtered_count += 1
                continue
            adx_col: str = [c for c in adx_df.columns if c.startswith("ADX_")][0]
            latest_adx: float = float(adx_df[adx_col].iloc[-1])
            if pd.notna(latest_adx) and latest_adx >= specs.min_trend_score:
                adx_scores.append((ticker, latest_adx))
            else:
                meta.adx_filtered_count += 1
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.discovery,
                    message=f"ADX calc failed for {ticker}: {str(e)[:128]}",
                    severity=Severity.warn,
                )
            )
            meta.adx_filtered_count += 1

    adx_scores.sort(key=lambda x: x[1], reverse=True)
    qualifying: list[str] = [t for t, _ in adx_scores]
    meta.top_adx_score = adx_scores[0][1] if adx_scores else -1.0

    meta.obs.metrics.extend(
        [
            MeasureMonad(
                name="screener_result_count", value=float(meta.catalog_source_result_count)
            ),
            MeasureMonad(
                name="asset_class_filtered",
                value=float(meta.asset_class_filtered_count),
            ),
            MeasureMonad(
                name="liquidity_filtered", value=float(meta.liquidity_filtered_count)
            ),
            MeasureMonad(name="adx_filtered", value=float(meta.adx_filtered_count)),
            MeasureMonad(name="qualifying_count", value=float(len(qualifying))),
        ]
    )

    _evaluate_alarms(meta, specs, len(qualifying))

    completed: datetime = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    record: DiscoveryProductOutput = DiscoveryProductOutput(
        session_id=run_base.session_id,
        universe_size=meta.catalog_source_result_count,
        qualifying_tickers=qualifying,
        min_trend_score_used=specs.min_trend_score,
        meta=meta,
    )

    try:
        store.put("discovery", record)
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.discovery,
                message=f"store.put failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    return record


if __name__ == "__main__":
    s: Settings = Settings()
    run(s.discovery, s.asset, s.run, s.store)
