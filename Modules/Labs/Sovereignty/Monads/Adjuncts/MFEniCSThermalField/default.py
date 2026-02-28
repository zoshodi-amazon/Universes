"""MFEniCSThermalField — Pure Heat transfer simulation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="fenics-thermalfield", help="Heat transfer simulation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """Heat transfer simulation from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Heat transfer simulation -> {output}")

if __name__ == "__main__":
    app()
