"""MKiCadCircuit — Pure PCB layout generation

params -> .kicad_pcb/.gerber (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="kicad-circuit", help="Generate PCB layout")


@app.command()
def circuit(
    output: Annotated[Path, typer.Option(help="Output file path")] = Path("out.kicad_pcb"),
    layers: Annotated[int, typer.Option(help="Number of copper layers")] = 2,
    width: Annotated[float, typer.Option(help="Board width mm")] = 100.0,
    height: Annotated[float, typer.Option(help="Board height mm")] = 100.0,
    trace_width: Annotated[float, typer.Option(help="Trace width mm")] = 0.25,
) -> None:
    """Generate PCB layout via KiCad Python API."""
    # TODO: wire to pcbnew Python bindings
    typer.echo(f"PCB {output} ({layers}L, {width}x{height}mm, trace={trace_width}mm)")


if __name__ == "__main__":
    app()
