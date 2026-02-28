"""MGodotGameProject — Pure Game project generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="godot-gameproject", help="Game project generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Game project from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Game project -> {output}")

if __name__ == "__main__":
    app()
