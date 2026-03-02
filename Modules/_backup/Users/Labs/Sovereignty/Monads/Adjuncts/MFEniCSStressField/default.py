"""MFEniCSStressField — Pure FEA structural analysis"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="fenics-stressfield", help="FEA structural analysis")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """FEA structural analysis from bounded params."""
    # TODO: wire to engine
    typer.echo(f"FEA structural analysis -> {output}")

if __name__ == "__main__":
    app()
