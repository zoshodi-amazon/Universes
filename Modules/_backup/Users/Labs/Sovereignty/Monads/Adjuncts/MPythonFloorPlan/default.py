"""MPythonFloorPlan — Pure physical space layout generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-floorplan", help="Physical space layout")

@app.command()
def floorplan(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.svg"),
    width: Annotated[float, typer.Option(help="Width meters")] = 10.0,
    depth: Annotated[float, typer.Option(help="Depth meters")] = 10.0,
    layers: Annotated[int, typer.Option(help="Number of layers")] = 1,
) -> None:
    """Generate floor plan layout."""
    typer.echo(f"FloorPlan {width}x{depth}m, {layers} layers -> {output}")

if __name__ == "__main__":
    app()
