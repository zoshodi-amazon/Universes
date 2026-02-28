"""MPythonTilemap — Pure 2D tile grid generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-tilemap", help="2D tile grid generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate 2D tile grid from bounded params."""
    # TODO: wire to engine
    typer.echo(f"2D tile grid -> {output}")

if __name__ == "__main__":
    app()
