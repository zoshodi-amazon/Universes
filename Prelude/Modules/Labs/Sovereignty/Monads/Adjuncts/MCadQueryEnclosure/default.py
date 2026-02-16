"""MCadQueryEnclosure — Pure enclosure/case generation

params -> .stl/.step (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="cadquery-enclosure", help="Generate enclosure/case")


@app.command()
def enclosure(
    output: Annotated[Path, typer.Option(help="Output file path")] = Path("out.stl"),
    width: Annotated[float, typer.Option(help="Inner width mm")] = 80.0,
    height: Annotated[float, typer.Option(help="Inner height mm")] = 50.0,
    depth: Annotated[float, typer.Option(help="Inner depth mm")] = 120.0,
    wall: Annotated[float, typer.Option(help="Wall thickness mm")] = 2.0,
    material: Annotated[str, typer.Option(help="pla|petg|aluminum|acrylic|wood")] = "pla",
) -> None:
    """Generate parametric enclosure via CadQuery."""
    import cadquery as cq

    outer = cq.Workplane("XY").box(width + 2 * wall, height + 2 * wall, depth + 2 * wall)
    inner = cq.Workplane("XY").box(width, height, depth).translate((0, 0, wall))
    result = outer.cut(inner)
    cq.exporters.export(result, str(output))
    typer.echo(f"Enclosure {output} ({width}x{height}x{depth}mm, wall={wall}mm, {material})")


if __name__ == "__main__":
    app()
