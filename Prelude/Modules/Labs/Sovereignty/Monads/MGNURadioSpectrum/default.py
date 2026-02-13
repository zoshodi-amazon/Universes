"""MGNURadioSpectrum — Pure spectrum capture from SDR params"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="gnuradio-spectrum", help="Frequency domain capture")

@app.command()
def spectrum(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
    freq_start: Annotated[float, typer.Option(help="Start freq MHz")] = 88.0,
    freq_end: Annotated[float, typer.Option(help="End freq MHz")] = 108.0,
    bandwidth: Annotated[float, typer.Option(help="Bandwidth kHz")] = 200.0,
    gain: Annotated[float, typer.Option(help="Gain dB")] = 30.0,
    duration: Annotated[float, typer.Option(help="Duration seconds")] = 10.0,
) -> None:
    """Capture frequency spectrum via GNU Radio."""
    # TODO: wire to osmosdr/soapy source -> FFT -> file sink
    typer.echo(f"Spectrum {freq_start}-{freq_end}MHz, bw={bandwidth}kHz, gain={gain}dB, {duration}s -> {output}")

if __name__ == "__main__":
    app()
