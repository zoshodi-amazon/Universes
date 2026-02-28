"""MCadQueryMesh — Pure 3D mesh generation from params

params -> .stl/.step/.3mf (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="cadquery-mesh", help="Generate 3D mesh from params")


@app.command()
def mesh(
    output: Annotated[Path, typer.Option(help="Output file path")] = Path("out.stl"),
    material: Annotated[str, typer.Option(help="pla|petg|abs|tpu|nylon|resin|metal")] = "pla",
    resolution: Annotated[float, typer.Option(help="Resolution in mm")] = 0.2,
    width: Annotated[float, typer.Option(help="Width in mm")] = 100.0,
    height: Annotated[float, typer.Option(help="Height in mm")] = 100.0,
    depth: Annotated[float, typer.Option(help="Depth in mm")] = 100.0,
) -> None:
    """Generate 3D solid geometry via CadQuery."""
    import cadquery as cq

    result = cq.Workplane("XY").box(width, height, depth)
    cq.exporters.export(result, str(output))
    typer.echo(f"Exported {output} ({material}, {resolution}mm res)")


if __name__ == "__main__":
    app()
