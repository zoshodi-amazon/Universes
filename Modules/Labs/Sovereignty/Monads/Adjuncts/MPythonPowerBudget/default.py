"""MPythonPowerBudget — Pure electrical load analysis

Deterministic: same config -> same power budget.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-powerbudget", help="Electrical load analysis")


@app.command()
def powerbudget(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH")] = Path("default.json"),
    voltage: Annotated[str, typer.Option(help="5V | 12V | 24V | 48V")] = "12V",
    safety_margin: Annotated[float, typer.Option(help="Safety margin 0.0-1.0")] = 0.2,
) -> None:
    """Compute power budget from energy config."""
    cfg = json.loads(config.read_text()) if config.exists() else {}
    energy = cfg.get("energy", {})

    gen_capacity_W = energy.get("generation", {}).get("capacity", {}).get("value", 100.0)
    storage_Wh = energy.get("storage", {}).get("capacity", {}).get("value", 1000.0)

    typer.echo(f"=== Power Budget ({voltage}) ===")
    typer.echo(f"  Generation: {gen_capacity_W:.0f}W")
    typer.echo(f"  Storage: {storage_Wh:.0f}Wh")
    typer.echo(f"  Safety margin: {safety_margin:.0%}")
    typer.echo(f"  Usable: {storage_Wh * (1 - safety_margin):.0f}Wh")
    if gen_capacity_W > 0:
        typer.echo(f"  Autonomy at 50W: {storage_Wh * (1 - safety_margin) / 50:.1f}hr")


if __name__ == "__main__":
    app()
