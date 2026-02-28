"""MPythonPlantProfile — Pure Plant profile generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-plantprofile", help="Plant profile generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Plant profile from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Plant profile -> {output}")

if __name__ == "__main__":
    app()
