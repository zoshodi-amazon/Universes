"""MKiCadSchematic — Pure circuit schematic generation

params -> .kicad_sch/.pdf/.svg (deterministic)
"""
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="kicad-schematic", help="Generate circuit schematic")


@app.command()
def schematic(
    output: Annotated[Path, typer.Option(help="Output file path")] = Path("out.kicad_sch"),
    components: Annotated[int, typer.Option(help="Number of components")] = 10,
    nets: Annotated[int, typer.Option(help="Number of nets")] = 20,
    format: Annotated[str, typer.Option(help="kicad_sch|pdf|svg")] = "kicad_sch",
) -> None:
    """Generate circuit schematic via KiCad Python API."""
    # TODO: wire to kicad-skip or eeschema Python bindings
    typer.echo(f"Schematic {output} ({components} components, {nets} nets, {format})")


if __name__ == "__main__":
    app()
