"""MRDKitMolecule — Pure Molecular structure generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="rdkit-molecule", help="Molecular structure generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Molecular structure from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Molecular structure -> {output}")

if __name__ == "__main__":
    app()
