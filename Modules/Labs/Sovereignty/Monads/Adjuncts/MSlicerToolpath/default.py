"""MSlicerToolpath — Pure gcode generation from mesh + print params

mesh + params -> .gcode (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="slicer-toolpath", help="Generate gcode from mesh")


@app.command()
def toolpath(
    input: Annotated[Path, typer.Option(help="Input .stl file")],
    output: Annotated[Path, typer.Option(help="Output .gcode file")] = Path("out.gcode"),
    layer_height: Annotated[float, typer.Option(help="Layer height in mm")] = 0.2,
    speed: Annotated[float, typer.Option(help="Print speed mm/s")] = 60.0,
    temperature: Annotated[int, typer.Option(help="Nozzle temp C")] = 210,
) -> None:
    """Slice STL to gcode via slicer engine."""
    # TODO: wire to PrusaSlicer/CuraEngine CLI
    typer.echo(f"Slicing {input} -> {output} (layer={layer_height}mm, speed={speed}mm/s, temp={temperature}C)")


if __name__ == "__main__":
    app()
