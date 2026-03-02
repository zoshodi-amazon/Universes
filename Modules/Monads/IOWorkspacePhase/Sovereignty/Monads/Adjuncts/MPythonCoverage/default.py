"""MPythonCoverage — Pure RF/sensor coverage overlay computation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-coverage", help="RF/sensor coverage overlay")

@app.command()
def coverage(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.geotiff"),
    lat: Annotated[float, typer.Option(help="Center latitude")] = 30.0,
    lon: Annotated[float, typer.Option(help="Center longitude")] = -97.0,
    radius: Annotated[float, typer.Option(help="Radius km")] = 10.0,
    freq: Annotated[float, typer.Option(help="Frequency MHz")] = 915.0,
) -> None:
    """Compute RF coverage overlay."""
    typer.echo(f"Coverage ({lat},{lon}) r={radius}km f={freq}MHz -> {output}")

if __name__ == "__main__":
    app()
