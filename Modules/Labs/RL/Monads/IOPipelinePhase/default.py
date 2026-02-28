"""IOPipelinePhase [Plasma] — Full pipeline: Discovery -> Ingest -> Feature -> (Train -> Eval)*.

Own BaseSettings + default.json. No cross-phase imports for settings.
"""
import time
import uuid
import numpy as np
import pandas as pd
import torch
from pathlib import Path
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.UnitTypes.EnvUnit.default import EnvUnit
from Types.UnitTypes.ErrorUnit.default import ErrorUnit, PhaseId as ErrPhaseId
from Types.PhaseInputTypes.DiscoveryInput.default import DiscoveryInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.PhaseInputTypes.TrainInput.default import TrainInput
from Types.PhaseInputTypes.EvalInput.default import EvalInput
from Types.PhaseInputTypes.PipelineInput.default import PipelineInput
from Types.PhaseOutputTypes.PipelineOutput.default import PipelineOutput, PipelineStatus

from Monads.IODiscoveryPhase.default import run as discover, Settings as DiscoverySettings
from Monads.IOIngestPhase.default import run as ingest
from Monads.IOFeaturePhase.default import run as feature
from Monads.IOTrainPhase.default import run as train
from Monads.IOEvalPhase.default import run as evaluate


class Settings(BaseSettings):
    """IOPipelinePhase Settings [Plasma] — Composes all phase configs for full pipeline execution."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOPipelinePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="pipeline",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    discovery: DiscoveryInput = Field(default=DiscoveryInput(io_universe=[]), description="Discovery config — screener, ADX threshold, universe")
    ingest: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")
    feature: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")
    train: TrainInput = Field(default=TrainInput(), description="Train config — algorithm, timesteps, learning rate, envs")
    eval: EvalInput = Field(default=EvalInput(), description="Eval config — forward window, profit threshold")
    pipeline: PipelineInput = Field(default=PipelineInput(), description="Pipeline config — walk-forward stride, train/eval split")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


def run(settings: Settings) -> PipelineOutput:
    t0 = time.time()
    errors: list[ErrorUnit] = []

    np.random.seed(settings.run.seed)
    torch.manual_seed(settings.run.seed)

    disc_settings = DiscoverySettings(
        asset=settings.asset, run=settings.run, discovery=settings.discovery,
    )
    discovery_record = discover(disc_settings)

    if not discovery_record.qualifying_tickers:
        errors.append(ErrorUnit(phase=ErrPhaseId.pipeline, message="no qualifying tickers"))
        record = PipelineOutput(
            run_id=settings.run.run_id, n_windows=0, win_rate_pct=0.0,
            duration_s=min(time.time() - t0, 86400.0),
            status=PipelineStatus.failed, errors=errors,
        )
        _write(record, settings.run)
        return record

    chosen = discovery_record.qualifying_tickers[0]
    asset = settings.asset.model_copy(update={"io_ticker": chosen})

    ingest_record = ingest(settings.ingest, asset, settings.run)
    feature_record = feature(ingest_record, settings.feature, settings.run)

    df = pd.read_pickle(feature_record.io_data_path)
    train_bars = settings.train.episode_duration_min // asset.interval_min
    eval_bars = settings.eval.forward_steps_min // asset.interval_min
    stride_bars = settings.pipeline.stride_min // asset.interval_min
    split_idx = int(len(df) * settings.pipeline.train_split_pct / 100.0)
    train_pool = df.iloc[:split_idx]
    n_windows = max(0, (len(train_pool) - train_bars - eval_bars) // stride_bars + 1)

    if n_windows == 0:
        errors.append(ErrorUnit(phase=ErrPhaseId.pipeline, message="not enough data"))
        record = PipelineOutput(
            run_id=settings.run.run_id, n_windows=0, win_rate_pct=0.0,
            duration_s=min(time.time() - t0, 86400.0),
            status=PipelineStatus.failed, errors=errors,
        )
        _write(record, settings.run)
        return record

    results = []
    for i in range(n_windows):
        start = i * stride_bars
        train_end = start + train_bars
        eval_end = train_end + eval_bars
        train_slice = train_pool.iloc[start:train_end + 1].copy()
        eval_slice = train_pool.iloc[train_end:eval_end + 1].copy()

        try:
            train_record = train(feature_record, settings.train, settings.env, asset, settings.run, train_slice)
            eval_record = evaluate(train_record, settings.eval, settings.env, asset, settings.run, i, eval_slice)
            results.append(eval_record)
        except Exception as e:
            errors.append(ErrorUnit(phase=ErrPhaseId.pipeline, message=str(e)[:1024], window_index=i))

    wins = sum(1 for r in results if r.threshold_met)

    record = PipelineOutput(
        run_id=settings.run.run_id,
        n_windows=len(results),
        win_rate_pct=round(100.0 * wins / len(results), 2) if results else 0.0,
        duration_s=min(time.time() - t0, 86400.0),
        status=PipelineStatus.success if not errors else PipelineStatus.partial,
        results=results, errors=errors,
    )

    _write(record, settings.run)
    return record


def _write(record: PipelineOutput, run_base: RunUnit) -> None:
    out = Path(run_base.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"pipeline_{run_base.run_ts}_{run_base.run_id}.json").write_text(record.model_dump_json(indent=2))


if __name__ == "__main__":
    run(Settings())
