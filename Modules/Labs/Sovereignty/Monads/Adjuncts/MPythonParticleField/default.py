"""MPythonParticleField — Pure N-body particle simulation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-particlefield", help="N-body particle simulation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """N-body particle simulation from bounded params."""
    # TODO: wire to engine
    typer.echo(f"N-body particle simulation -> {output}")

if __name__ == "__main__":
    app()
