"""MBlenderAnimation — Pure Animation generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="blender-animation", help="Animation generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Animation from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Animation -> {output}")

if __name__ == "__main__":
    app()
