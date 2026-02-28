"""MGNURadioWaveform — Pure time domain capture from SDR params"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="gnuradio-waveform", help="Time domain capture")

@app.command()
def waveform(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.sigmf"),
    sample_rate: Annotated[int, typer.Option(help="Sample rate Hz")] = 2_400_000,
    channels: Annotated[int, typer.Option(help="IQ channels")] = 2,
    duration: Annotated[float, typer.Option(help="Duration seconds")] = 10.0,
) -> None:
    """Capture time domain waveform via GNU Radio."""
    # TODO: wire to osmosdr/soapy source -> file sink
    typer.echo(f"Waveform {sample_rate}Hz, {channels}ch, {duration}s -> {output}")

if __name__ == "__main__":
    app()
