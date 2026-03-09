"""IOFeaturePhase [QGP] — IngestProductOutput + FeatureHom -> FeatureProductOutput.

Wavelet denoise OHLCV + trend proxy. Blob written to store via StoreMonad.put().
Reads ingest blob from store via StoreMonad.get().
"""

from datetime import datetime, timezone
import numpy as np
import pandas as pd
import pywt
import pandas_ta as ta
from pathlib import Path
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Hom.Feature.default import FeatureHom
from Types.Product.Feature.Output.default import FeatureProductOutput
from Types.Product.Ingest.Output.default import IngestProductOutput
from Types.Identity.Asset.default import AssetIdentity
from Types.Identity.Run.default import RunIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Product.Feature.Meta.default import FeatureProductMeta
from Types.Monad.Store.default import StoreMonad
from Types.IO.IOIngestPhase.default import run as ingest

N_DYNAMIC_FEATURES = 2


def _wavelet_denoise(
    signal: np.ndarray, wavelet: str, level: int, mode: str
) -> np.ndarray:
    coeffs = pywt.wavedec(signal, wavelet, level=level)
    sigma = np.median(np.abs(coeffs[-1])) / 0.6745
    thresh = sigma * np.sqrt(2 * np.log(len(signal)))
    denoised_coeffs = [coeffs[0]] + [
        pywt.threshold(c, thresh, mode=mode) for c in coeffs[1:]
    ]
    rec = pywt.waverec(denoised_coeffs, wavelet)
    return rec[: len(signal)]


def _upsample(coeff: np.ndarray, n: int) -> np.ndarray:
    return np.interp(np.linspace(0, 1, n), np.linspace(0, 1, len(coeff)), coeff)


def run(
    ingest_record: IngestProductOutput,
    specs: FeatureHom,
    run_base: RunIdentity,
    store_base: StoreMonad,
) -> FeatureProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = FeatureProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.feature
    meta.wavelet_level_used = specs.level

    store = store_base.model_copy(
        update={"run_id": run_base.run_id, "phase": PhaseId.feature}
    )

    # Retrieve ingest blob path from store
    try:
        ingest_row = store.get(run_base.run_id, PhaseId.ingest.value, "ingest")
        blob_path = ingest_row.blob_path
    except KeyError:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"ingest artifact not found in store for run_id={run_base.run_id}",
                severity=Severity.error,
            )
        )
        raise ValueError(
            f"ingest artifact not found in store for run_id={run_base.run_id}"
        )

    if not Path(blob_path).exists():
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"ingest blob not found on disk: {blob_path}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"ingest blob not found on disk: {blob_path}")

    try:
        df = pd.read_pickle(blob_path)
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"failed to read ingest blob: {str(e)[:128]}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"failed to read ingest blob: {str(e)[:128]}")

    if len(df) == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message="empty DataFrame from ingest",
                severity=Severity.error,
            )
        )
        raise ValueError("empty DataFrame from ingest")

    n = len(df)
    channels = ["open", "high", "low", "close", "volume"]

    for ch in channels:
        try:
            signal = df[ch].values.copy()
            denoised = _wavelet_denoise(
                signal, specs.wavelet.value, specs.level, specs.threshold_mode.value
            )
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
            df[f"feature_{ch}_detail_energy"] = (
                detail_energy / max_e if max_e > 0 else detail_energy
            ).clip(0.0, 1.0)
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.feature,
                    message=f"wavelet processing failed for {ch}: {str(e)[:64]}",
                    severity=Severity.warn,
                )
            )

    try:
        adx_df = ta.adx(df["high"], df["low"], df["close"], length=specs.adx_period)
        if adx_df is not None:
            adx_col = [c for c in adx_df.columns if c.startswith("ADX_")][0]
            df["feature_adx"] = (adx_df[adx_col].fillna(0.0) / 100.0).clip(0.0, 1.0)
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"ADX calculation failed: {str(e)[:64]}",
                severity=Severity.warn,
            )
        )

    try:
        st_df = ta.supertrend(
            df["high"],
            df["low"],
            df["close"],
            length=specs.supertrend_period,
            multiplier=specs.supertrend_multiplier,
        )
        if st_df is not None:
            dir_col = [c for c in st_df.columns if c.startswith("SUPERTd_")][0]
            df["feature_supertrend_dir"] = (
                st_df[dir_col].fillna(0.0).astype(float).clip(-1.0, 1.0)
            )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"SuperTrend calculation failed: {str(e)[:64]}",
                severity=Severity.warn,
            )
        )

    if "feature_adx" in df.columns:
        df["feature_regime"] = (
            df["feature_adx"] >= specs.regime_threshold / 100.0
        ).astype(float)
        meta.regime_trending_pct = float(df["feature_regime"].mean() * 100.0)

    feature_cols = [c for c in df.columns if c.startswith("feature_")]
    before_drop = len(df)
    df = df.dropna(subset=feature_cols)
    meta.nan_rows_dropped = before_drop - len(df)

    if len(feature_cols) > 1:
        try:
            corr_matrix = df[feature_cols].corr().abs()
            np.fill_diagonal(corr_matrix.values, 0)
            meta.feature_correlation_max = float(corr_matrix.max().max())
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.feature,
                    message=f"correlation computation failed: {str(e)[:64]}",
                    severity=Severity.warn,
                )
            )

    feature_names = sorted([c for c in df.columns if c.startswith("feature_")])

    out_blob = store.blob_path_for("features", ext="pkl")
    try:
        df.to_pickle(str(out_blob))
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"blob write failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    record = FeatureProductOutput(
        run_id=run_base.run_id,
        n_static_features=len(feature_names),
        n_dynamic_features=N_DYNAMIC_FEATURES,
        n_valid_bars=len(df),
        feature_names=feature_names,
        meta=meta,
    )

    try:
        store.put("features", record, blob_path=str(out_blob))
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.feature,
                message=f"store.put failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    return record


class Settings(BaseSettings):
    """IOFeaturePhase Settings [Plasma] — Standalone entrypoint for feature engineering (4 fields)."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOFeaturePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="cata-feature",
    )
    asset: AssetIdentity = Field(
        ..., description="Asset index — ticker, interval, trade hours, holidays"
    )
    run: RunIdentity = Field(
        default=RunIdentity(), description="Run context — ID, seed, store"
    )
    store: StoreMonad = Field(
        default_factory=StoreMonad, description="Artifact store — DB + blob dir"
    )
    feature: FeatureHom = Field(
        default=FeatureHom(),
        description="Feature config — wavelet, trend indicators, regime threshold",
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
    from Types.Hom.Ingest.default import IngestHom

    s = Settings()
    ingest_record = ingest(IngestHom(), s.asset, s.run, s.store)
    run(ingest_record, s.feature, s.run, s.store)
