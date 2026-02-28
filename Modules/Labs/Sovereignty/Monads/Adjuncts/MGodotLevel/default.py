"""MGodotLevel — Pure Game level generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="godot-level", help="Game level generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Game level from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Game level -> {output}")

if __name__ == "__main__":
    app()
