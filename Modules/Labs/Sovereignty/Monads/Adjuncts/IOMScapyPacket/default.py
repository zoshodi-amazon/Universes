"""IOMScapyPacket — Effectful: Packet injection (live network)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-scapy-packet", help="Packet injection (live network)")

@app.command()
def run() -> None:
    """Packet injection (live network). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Packet injection (live network)")

if __name__ == "__main__":
    app()
