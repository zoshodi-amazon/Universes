"""MCadQueryPattern — Pure 2D cut profile generation

params -> .svg/.dxf (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="cadquery-pattern", help="Generate 2D cut pattern")


@app.command()
def pattern(
    output: Annotated[Path, typer.Option(help="Output file path")] = Path("out.svg"),
    material: Annotated[str, typer.Option(help="acrylic|plywood|leather|fabric")] = "acrylic",
    thickness: Annotated[float, typer.Option(help="Material thickness mm")] = 3.0,
    width: Annotated[float, typer.Option(help="Width mm")] = 300.0,
    height: Annotated[float, typer.Option(help="Height mm")] = 300.0,
) -> None:
    """Generate 2D cut profile via CadQuery."""
    import cadquery as cq

    result = cq.Workplane("XY").rect(width, height)
    cq.exporters.export(result, str(output))
    typer.echo(f"Exported {output} ({material}, {thickness}mm)")


if __name__ == "__main__":
    app()
