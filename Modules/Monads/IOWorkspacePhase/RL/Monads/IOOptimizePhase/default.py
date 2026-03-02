"""IOOptimizePhase [Plasma] — hyperparameter search: Optuna trials over IOMainPhase.

Own BaseSettings + default.json. JournalStorage for parallel-safe trials.
"""
import uuid
import time
from pathlib import Path
import optuna
from optuna.storages.journal import JournalStorage, JournalFileBackend
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.UnitTypes.EnvUnit.default import EnvUnit
from Types.PhaseInputTypes.DiscoveryInput.default import DiscoveryInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.PhaseInputTypes.TrainInput.default import TrainInput
from Types.PhaseInputTypes.EvalInput.default import EvalInput
from Types.PhaseInputTypes.PipelineInput.default import PipelineInput
from Types.PhaseInputTypes.OptimizeInput.default import OptimizeInput
from Types.PhaseOutputTypes.OptimizeOutput.default import OptimizeOutput

from Monads.IOMainPhase.default import run as pipeline, Settings as PipelineSettings


class Settings(BaseSettings):
    """IOOptimizePhase Settings [Plasma] — Composes all phase configs + Optuna search params for hyperparameter optimization."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOOptimizePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="optimize",
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
    optimize: OptimizeInput = Field(default=OptimizeInput(), description="Optuna config — trials, parallelism, search space bounds")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


def _objective(trial: optuna.Trial, settings: Settings):
    opt = settings.optimize
    lr = trial.suggest_float("learning_rate", opt.search_space_lr_min, opt.search_space_lr_max, log=True)
    timesteps = trial.suggest_int("total_timesteps", opt.search_space_timesteps_min, opt.search_space_timesteps_max)

    trial_train = settings.train.model_copy(update={"learning_rate": lr, "total_timesteps": timesteps})
    trial_run = settings.run.model_copy(update={"run_id": uuid.uuid4().hex[:8]})

    pipe_settings = PipelineSettings(
        asset=settings.asset, run=trial_run, env=settings.env,
        discovery=settings.discovery, ingest=settings.ingest, feature=settings.feature,
        train=trial_train, eval=settings.eval, pipeline=settings.pipeline,
    )
    pipe_record = pipeline(pipe_settings)

    trial.set_user_attr("run_ts", trial_run.run_ts)
    trial.set_user_attr("run_id", trial_run.run_id)

    if opt.objective_metric.value == "win_rate_pct":
        return pipe_record.win_rate_pct
    returns = [r.portfolio_return_pct for r in pipe_record.results]
    return sum(returns) / len(returns) if returns else 0.0


def run(settings: Settings) -> OptimizeOutput:
    opt = settings.optimize

    out = Path(settings.run.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    journal_path = out / f"study_{settings.run.run_ts}_{settings.run.run_id}.log"

    storage = JournalStorage(JournalFileBackend(str(journal_path)))
    study = optuna.create_study(
        direction="maximize", storage=storage,
        study_name=settings.run.run_id, load_if_exists=True,
    )

    optuna.logging.set_verbosity(optuna.logging.WARNING)
    study.optimize(
        lambda trial: _objective(trial, settings),
        n_trials=opt.n_trials, n_jobs=opt.n_parallel,
    )

    best = study.best_trial
    best_run_ts = best.user_attrs["run_ts"]
    best_run_id = best.user_attrs["run_id"]
    best_model_path = str(out / f"model_{best_run_ts}_{best_run_id}.zip")

    record = OptimizeOutput(
        run_id=settings.run.run_id,
        n_completed=len(study.trials),
        io_model_path=best_model_path,
        best_lr=best.params["learning_rate"],
        best_timesteps=best.params["total_timesteps"],
        best_win_rate_pct=max(0.0, min(100.0, best.value)) if opt.objective_metric.value == "win_rate_pct" else 0.0,
        io_study_path=str(journal_path),
    )

    (out / f"optimize_{settings.run.run_ts}_{settings.run.run_id}.json").write_text(record.model_dump_json(indent=2))
    return record


if __name__ == "__main__":
    run(Settings())
