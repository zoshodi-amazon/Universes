"""MGDALTerrain — Pure offline map tile generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="gdal-terrain", help="Offline map generation")

@app.command()
def terrain(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.mbtiles"),
    bounds: Annotated[str, typer.Option(help="minlon,minlat,maxlon,maxlat")] = "0,0,1,1",
    zoom: Annotated[int, typer.Option(help="Zoom level 1-20")] = 14,
    source: Annotated[str, typer.Option(help="osm|srtm|copernicus")] = "osm",
) -> None:
    """Generate offline map tiles via GDAL/rasterio."""
    typer.echo(f"Terrain bounds={bounds}, zoom={zoom}, source={source} -> {output}")

if __name__ == "__main__":
    app()
