"""MBlenderScene3D — Pure 3D scene generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="blender-scene3d", help="3D scene generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate 3D scene from bounded params."""
    # TODO: wire to engine
    typer.echo(f"3D scene -> {output}")

if __name__ == "__main__":
    app()
