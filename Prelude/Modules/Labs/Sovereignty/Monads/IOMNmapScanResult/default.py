"""IOMNmapScanResult — Effectful: Network scan (live network)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-nmap-scanresult", help="Network scan (live network)")

@app.command()
def run() -> None:
    """Network scan (live network). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Network scan (live network)")

if __name__ == "__main__":
    app()
