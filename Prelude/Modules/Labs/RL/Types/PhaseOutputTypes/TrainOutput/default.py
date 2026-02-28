"""TrainOutput [Gas] — Train phase output (<=7 params). Self-contained."""
from pydantic import BaseModel, Field, constr
from Types.PhaseInputTypes.TrainInput.default import AlgoName
import uuid

RunId = constr(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)
FilePath = constr(min_length=1, max_length=512, pattern=r"^[A-Za-z0-9_\-./]+$")

class TrainOutput(BaseModel):
    """TrainOutput [Gas] — Result of RL training: saved model, normalization stats, and final reward."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    io_model_path: FilePath = Field(..., description="File path to the saved SB3 model zip")
    algo: AlgoName = Field(..., description="RL algorithm used for training — PPO, SAC, DQN, or A2C")
    total_timesteps: int = Field(ge=1, le=100_000_000, description="Total training steps completed across all environments")
    learning_rate: float = Field(ge=1e-8, le=1.0, description="Optimizer learning rate used during training")
    final_reward: float = Field(ge=-1e6, le=1e6, description="Last recorded reward from the training environment")
    io_normalize_path: FilePath = Field(..., description="File path to the saved VecNormalize running stats pickle")
