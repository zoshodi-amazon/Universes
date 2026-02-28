"""MPythonSynthesis — Pure Waveform synthesis generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-synthesis", help="Waveform synthesis generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Waveform synthesis from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Waveform synthesis -> {output}")

if __name__ == "__main__":
    app()
