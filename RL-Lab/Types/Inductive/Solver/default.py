"""SolverInductive [Inductive] — RL algorithm sum type (ADT, 4 variants).

Crystalline phase — a finite sum type (A + B + C + D) is an ADT, not a terminal
object. Phase placement follows type theory: a 4-variant enum is Inductive
(Crystalline), not Identity (BEC). BEC/Identity types have exactly one inhabitant.

Shared across SolveHom, ProjectHom, SolveProductOutput without cross-Hom imports
because it lives at the Inductive layer, which all higher layers may import.
"""
from enum import Enum


class SolverInductive(str, Enum):
    """SolverInductive [Inductive] — Named RL algorithm enum for SB3 dispatch (4 variants)."""
    PPO = "PPO"
    SAC = "SAC"
    DQN = "DQN"
    A2C = "A2C"
