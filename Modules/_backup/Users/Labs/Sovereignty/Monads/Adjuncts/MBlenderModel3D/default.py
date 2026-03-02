"""MBlenderModel3D — Pure 3D model generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="blender-model3d", help="3D model generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate 3D model from bounded params."""
    # TODO: wire to engine
    typer.echo(f"3D model -> {output}")

if __name__ == "__main__":
    app()
