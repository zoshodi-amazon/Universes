"""MPythonSprite — Pure 2D pixel art generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-sprite", help="2D pixel art generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate 2D pixel art from bounded params."""
    # TODO: wire to engine
    typer.echo(f"2D pixel art -> {output}")

if __name__ == "__main__":
    app()
