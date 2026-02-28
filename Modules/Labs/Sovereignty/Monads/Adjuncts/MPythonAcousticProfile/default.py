"""MPythonAcousticProfile — Pure acoustic response computation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-acousticprofile", help="Acoustic response profile")

@app.command()
def acousticprofile(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.wav"),
    impulse_length: Annotated[float, typer.Option(help="Impulse length ms")] = 500.0,
    sample_rate: Annotated[int, typer.Option(help="Sample rate Hz")] = 44100,
    channels: Annotated[int, typer.Option(help="Channels")] = 1,
) -> None:
    """Compute acoustic impulse response."""
    # TODO: wire to scipy.signal or pyroomacoustics
    typer.echo(f"Acoustic profile {impulse_length}ms, {sample_rate}Hz, {channels}ch -> {output}")

if __name__ == "__main__":
    app()
