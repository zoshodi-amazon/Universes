"""CoIOSimulationPhase [CoIO] — Observer for Simulation phase, dual of IOSimulationPhase.

Probes Simulation phase artifacts and produces CoSimulationProductOutput + CoSimulationProductMeta.
"""

from __future__ import annotations


def observe() -> None:
    """Execute the Simulation phase observer."""
    raise NotImplementedError("CoIOSimulationPhase not yet implemented")


if __name__ == "__main__":
    observe()
