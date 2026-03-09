"""PipelineHom [Hom] — Composite of per-phase Hom configs for pipeline orchestration (5 fields).

Liquid phase — morphism flowing into IOMainPhase. Where individual Hom types
configure single phases, PipelineHom bundles all sub-phase configs into a single
morphism that IOMainPhase destructures during walk-forward execution.

Fields satisfy Independence, Completeness, Locality:
- discovery: screener + ADX filter config — independent of data pipeline
- ingest:    data download + cache config — independent of feature engineering
- feature:   wavelet + indicator config — independent of training
- train:     RL algorithm + timesteps config — independent of evaluation
- eval:      forward window config — independent of training
"""
from pydantic import BaseModel, Field

from Types.Hom.Discovery.default import DiscoveryHom
from Types.Hom.Ingest.default import IngestHom
from Types.Hom.Feature.default import FeatureHom
from Types.Hom.Train.default import TrainHom
from Types.Hom.Eval.default import EvalHom


class PipelineHom(BaseModel):
    """PipelineHom [Hom] — Composite of per-phase Hom configs for pipeline orchestration (5 fields)."""
    discovery: DiscoveryHom = Field(
        default_factory=lambda: DiscoveryHom(io_universe=[]),
        description="Discovery config — screener, ADX threshold, universe")
    ingest: IngestHom = Field(
        default_factory=IngestHom,
        description="Ingest config — lookback period, warmup bars")
    feature: FeatureHom = Field(
        default_factory=FeatureHom,
        description="Feature config — wavelet, trend indicators, regime threshold")
    train: TrainHom = Field(
        default_factory=TrainHom,
        description="Train config — algorithm, timesteps, learning rate, envs")
    eval: EvalHom = Field(
        default_factory=EvalHom,
        description="Eval config — forward window length")
