"""MPVLibEnergyForecast — Pure Solar energy yield forecast"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="pvlib-energyforecast", help="Solar energy yield forecast")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """Solar energy yield forecast from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Solar energy yield forecast -> {output}")

if __name__ == "__main__":
    app()
