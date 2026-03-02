"""MPythonFluidSim — Pure CFD simulation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-fluidsim", help="CFD simulation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """CFD simulation from bounded params."""
    # TODO: wire to engine
    typer.echo(f"CFD simulation -> {output}")

if __name__ == "__main__":
    app()
