from dataclasses import dataclass, asdict
import json

@dataclass
class GameState:
    player_x: float = 0.0
    player_y: float = 0.0
    score: int = 0
    level: int = 1

def transition(state: GameState, action: str) -> GameState:
    """Pure state transition function"""
    if action == "move_right":
        return GameState(state.player_x + 1, state.player_y, state.score, state.level)
    elif action == "move_left":
        return GameState(state.player_x - 1, state.player_y, state.score, state.level)
    elif action == "score":
        return GameState(state.player_x, state.player_y, state.score + 10, state.level)
    return state
