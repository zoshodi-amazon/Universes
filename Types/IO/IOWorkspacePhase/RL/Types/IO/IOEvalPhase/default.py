"""IOEvalPhase [QGP] — TrainProductOutput + EvalHom -> EvalProductOutput.

Same env as Train. Loads model + VecNormalize from StoreMonad.
Per-step stop-loss and take-profit check. Returns EvalProductOutput only.
"""
from datetime import datetime, timezone
import numpy as np
import pandas as pd
import gymnasium as gym
from pathlib import Path
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import BaseSettings, PydanticBaseSettingsSource, SettingsConfigDict

from Types.Hom.Eval.default import EvalHom
from Types.Hom.Ingest.default import IngestHom
from Types.Hom.Feature.default import FeatureHom
from Types.Hom.Train.default import TrainHom
from Types.Dependent.Env.default import EnvDependent
from Types.Dependent.Risk.default import RiskDependent
from Types.Identity.Asset.default import AssetIdentity
from Types.Identity.Run.default import RunIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Product.Eval.Meta.default import EvalProductMeta
from Types.Product.Eval.Output.default import EvalProductOutput
from Types.Product.Train.Output.default import TrainProductOutput
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOFeaturePhase.default import run as feature
from Types.IO.IOTrainPhase.default import run as train

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}


def run(
    train_record: TrainProductOutput,
    eval_specs: EvalHom,
    env_base: EnvDependent,
    risk: RiskDependent,
    asset: AssetIdentity,
    run_base: RunIdentity,
    window_index: int,
    df_slice: pd.DataFrame,
) -> EvalProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = EvalProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.eval

    if len(df_slice) == 0:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message="empty DataFrame for eval",
            severity=Severity.error
        ))
        raise ValueError("empty DataFrame for eval")

    # Resolve model + normalize blob paths from store
    store = run_base.store.model_copy(update={"run_id": train_record.run_id, "phase": PhaseId.train})
    try:
        model_row = store.get(train_record.run_id, PhaseId.train.value, "model")
        normalize_row = store.get(train_record.run_id, PhaseId.train.value, "normalize")
        model_path = model_row.blob_path
        normalize_path = normalize_row.blob_path
    except KeyError as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message=f"artifact not found in store: {e}",
            severity=Severity.error
        ))
        raise ValueError(f"artifact not found in store: {e}")

    if not Path(model_path).exists():
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message=f"model blob not found: {model_path}",
            severity=Severity.error
        ))
        raise ValueError(f"model blob not found: {model_path}")
    if not Path(normalize_path).exists():
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message=f"normalize blob not found: {normalize_path}",
            severity=Severity.error
        ))
        raise ValueError(f"normalize blob not found: {normalize_path}")

    forward_bars = eval_specs.forward_steps_min // asset.interval_min

    def _make_env() -> gym.Env:
        env = gym.make(
            "TradingEnv", df=df_slice, positions=env_base.positions,
            portfolio_initial_value=float(env_base.initial_value),
            initial_position=0.0,
            trading_fees=env_base.fees_pct / 100.0,
            borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
            windows=None, max_episode_duration=forward_bars,
            name=env_base.broker_mode.value, verbose=run_base.verbose, render_mode="logs",
        )
        env.unwrapped.add_metric("Market Return", lambda history: f"{((history['data_close', -1] / history['data_close', 0]) - 1) * 100:.2f}%")
        env.unwrapped.add_metric("Position Changes", lambda history: np.sum(np.diff(history["position"]) != 0))
        return env

    try:
        eval_env = DummyVecEnv([_make_env])
        eval_env = VecNormalize.load(normalize_path, eval_env)
        eval_env.training = False
        eval_env.norm_reward = False
    except Exception as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message=f"env creation failed: {str(e)[:128]}",
            severity=Severity.error
        ))
        raise

    try:
        algo_cls = ALGOS[train_record.algo.value]
        model = algo_cls.load(model_path)

        obs = eval_env.reset()
        done = False
        final_info = {}
        threshold_met = False
        max_value = env_base.initial_value
        min_value = env_base.initial_value
        prev_pos = 0.0

        while not done:
            action, _ = model.predict(obs, deterministic=True)
            obs, reward, dones, infos = eval_env.step(action)
            done = dones[0]
            final_info = infos[0]
            meta.steps_taken += 1

            current_value = final_info.get("portfolio_valuation", env_base.initial_value)
            max_value = max(max_value, current_value)
            min_value = min(min_value, current_value)

            current_pos = float(final_info.get("position", 0.0))
            if current_pos != prev_pos:
                meta.position_changes += 1
                prev_pos = current_pos

            current_ret_pct = ((current_value - env_base.initial_value) / env_base.initial_value) * 100.0
            if current_ret_pct <= risk.stop_loss_pct:
                meta.stop_loss_triggered = True
                break
            if current_ret_pct >= risk.profit_threshold_pct:
                threshold_met = True
                meta.take_profit_triggered = True
                break

        if max_value > 0:
            meta.max_drawdown_pct = float(((min_value - max_value) / max_value) * 100.0)

        final_value = final_info.get("portfolio_valuation", env_base.initial_value)
        ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0
        pos = float(final_info.get("position", 0.0))

        flat_idx = env_base.positions.index(0.0)
        if pos != 0.0:
            obs, reward, dones, infos = eval_env.step([flat_idx])
            final_info = infos[0]
            final_value = final_info.get("portfolio_valuation", env_base.initial_value)
            ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0

        # Render logs under store blobs
        render_dir = Path(run_base.store.blob_dir) / run_base.run_id / "render_logs"
        render_dir.mkdir(parents=True, exist_ok=True)
        try:
            inner_env = eval_env.envs[0].unwrapped
            if hasattr(inner_env, 'df') and inner_env.df.index.tz is not None:
                inner_env.df.index = inner_env.df.index.tz_localize(None)
            inner_env.save_for_render(dir=str(render_dir))
        except Exception as e:
            meta.obs.errors.append(ErrorMonad(
                phase=PhaseId.eval,
                message=f"render save failed: {str(e)[:64]}",
                severity=Severity.warn
            ))
    except Exception as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.eval,
            message=f"evaluation failed: {str(e)[:128]}",
            severity=Severity.error
        ))
        raise
    finally:
        eval_env.close()

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (completed - datetime.fromisoformat(started.replace('Z', '+00:00'))).total_seconds()

    return EvalProductOutput(
        run_id=run_base.run_id, io_ticker=asset.io_ticker, window_index=window_index,
        portfolio_return_pct=max(-100.0, min(1000.0, ret_pct)),
        final_value=max(0.0, min(1e9, final_value)),
        threshold_met=threshold_met or ret_pct >= risk.profit_threshold_pct,
        meta=meta,
    )


class Settings(BaseSettings):
    """IOEvalPhase Settings [Plasma] — Standalone entrypoint for evaluation (runs ingest → feature → train first)."""
    model_config = SettingsConfigDict(
        json_file="Types/IO/IOEvalPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="eval",
    )
    asset: AssetIdentity = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunIdentity = Field(default=RunIdentity(), description="Run context — ID, seed, store")
    env: EnvDependent = Field(default=EnvDependent(), description="Trading environment — fees, positions, stop-loss, broker mode")
    risk: RiskDependent = Field(default_factory=RiskDependent, description="Risk gate — stop-loss and take-profit thresholds")
    ingest_cfg: IngestHom = Field(default=IngestHom(), description="Ingest config — lookback period, warmup")
    feature_cfg: FeatureHom = Field(default=FeatureHom(), description="Feature config — wavelet, trend indicators, regime threshold")
    train_cfg: TrainHom = Field(default=TrainHom(), description="Train config — algorithm, timesteps, learning rate, envs")
    eval: EvalHom = Field(default=EvalHom(), description="Eval config — forward window, profit threshold")

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
    ingest_record = ingest(s.ingest_cfg, s.asset, s.run)
    feature_record = feature(ingest_record, s.feature_cfg, s.run)
    store = s.run.store.model_copy(update={"run_id": s.run.run_id, "phase": PhaseId.feature})
    feat_row = store.get(s.run.run_id, PhaseId.feature.value, "features")
    df = pd.read_pickle(feat_row.blob_path)
    episode_bars = s.train_cfg.episode_duration_min // s.asset.interval_min
    eval_bars = s.eval.forward_steps_min // s.asset.interval_min
    train_slice = df.iloc[:episode_bars + 1].copy()
    eval_slice = df.iloc[episode_bars:episode_bars + eval_bars + 1].copy()
    train_record = train(feature_record, s.train_cfg, s.env, s.asset, s.run, train_slice)
    run(train_record, s.eval, s.env, s.risk, s.asset, s.run, 0, eval_slice)
