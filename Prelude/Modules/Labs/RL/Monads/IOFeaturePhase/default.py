"""IOFeaturePhase [Plasma] — IngestOutput + FeatureInput -> FeatureOutput.

Wavelet denoise OHLCV + trend proxy. All returns-based, never level-based.
Returns FeatureOutput only. No print.
"""
import numpy as np
import pandas as pd
import pywt
import pandas_ta as ta
from pathlib import Path
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseOutputTypes.FeatureOutput.default import FeatureOutput
from Types.PhaseOutputTypes.IngestOutput.default import IngestOutput
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Monads.IOIngestPhase.default import run as ingest

# gym-trading-env injects 2 dynamic features: last_position, real_position
N_DYNAMIC_FEATURES = 2


def _wavelet_denoise(signal: np.ndarray, wavelet: str, level: int, mode: str) -> np.ndarray:
    coeffs = pywt.wavedec(signal, wavelet, level=level)
    sigma = np.median(np.abs(coeffs[-1])) / 0.6745
    thresh = sigma * np.sqrt(2 * np.log(len(signal)))
    denoised_coeffs = [coeffs[0]] + [
        pywt.threshold(c, thresh, mode=mode) for c in coeffs[1:]
    ]
    rec = pywt.waverec(denoised_coeffs, wavelet)
    return rec[:len(signal)]


def _upsample(coeff: np.ndarray, n: int) -> np.ndarray:
    return np.interp(np.linspace(0, 1, n), np.linspace(0, 1, len(coeff)), coeff)


def run(
    ingest_record: IngestOutput,
    specs: FeatureInput,
    run_base: RunUnit,
) -> FeatureOutput:
    if not Path(ingest_record.io_data_path).exists():
        raise ValueError(f"ingest data not found: {ingest_record.io_data_path}")
    df = pd.read_pickle(ingest_record.io_data_path)
    if len(df) == 0:
        raise ValueError("empty DataFrame from ingest")
    n = len(df)
    channels = ["open", "high", "low", "close", "volume"]

    for ch in channels:
        signal = df[ch].values.copy()

        denoised = _wavelet_denoise(signal, specs.wavelet.value, specs.level, specs.threshold_mode.value)
        pct = pd.Series(denoised, index=df.index).pct_change().fillna(0.0)
        df[f"feature_{ch}_denoised_pct"] = pct.clip(-100.0, 100.0)

        coeffs = pywt.wavedec(signal, specs.wavelet.value, level=specs.level)
        approx = _upsample(coeffs[0], n)
        approx_pct = np.diff(approx, prepend=approx[0]) / (np.abs(approx) + 1e-10)
        df[f"feature_{ch}_approx_pct"] = np.clip(approx_pct, -10.0, 10.0)

        detail_energy = np.zeros(n)
        for c in coeffs[1:]:
            detail_energy += _upsample(c**2, n)
        max_e = np.max(detail_energy)
        df[f"feature_{ch}_detail_energy"] = (detail_energy / max_e if max_e > 0 else detail_energy).clip(0.0, 1.0)

    adx_df = ta.adx(df["high"], df["low"], df["close"], length=specs.adx_period)
    if adx_df is not None:
        adx_col = [c for c in adx_df.columns if c.startswith("ADX_")][0]
        df["feature_adx"] = (adx_df[adx_col].fillna(0.0) / 100.0).clip(0.0, 1.0)

    st_df = ta.supertrend(
        df["high"], df["low"], df["close"],
        length=specs.supertrend_period, multiplier=specs.supertrend_multiplier,
    )
    if st_df is not None:
        dir_col = [c for c in st_df.columns if c.startswith("SUPERTd_")][0]
        df["feature_supertrend_dir"] = st_df[dir_col].fillna(0.0).astype(float).clip(-1.0, 1.0)

    if "feature_adx" in df.columns:
        df["feature_regime"] = (df["feature_adx"] >= specs.regime_threshold / 100.0).astype(float)

    feature_names = sorted([c for c in df.columns if c.startswith("feature_")])

    out = Path(run_base.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    data_path = out / f"features_{run_base.run_ts}_{run_base.run_id}.pkl"
    df.to_pickle(str(data_path))

    return FeatureOutput(
        run_id=run_base.run_id,
        n_static_features=len(feature_names),
        n_dynamic_features=N_DYNAMIC_FEATURES,
        feature_names=feature_names,
        n_valid_bars=len(df),
        io_data_path=str(data_path),
    )


class Settings(BaseSettings):
    """IOFeaturePhase Settings [Plasma] — Standalone entrypoint for feature engineering (runs ingest first)."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOFeaturePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="feature",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    ingest: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")
    feature: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    ingest_record = ingest(s.ingest, s.asset, s.run)
    run(ingest_record, s.feature, s.run)
