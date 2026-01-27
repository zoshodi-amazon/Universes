from ...Options.index import StateConfig
from ..State.index import GameState, asdict
from pathlib import Path
import json

cfg = StateConfig()

def save(state: GameState, slot: str = "default"):
    path = Path(cfg.save_dir) / f"{slot}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(asdict(state)))

def load(slot: str = "default") -> GameState:
    path = Path(cfg.save_dir) / f"{slot}.json"
    if path.exists():
        return GameState(**json.loads(path.read_text()))
    return GameState()
