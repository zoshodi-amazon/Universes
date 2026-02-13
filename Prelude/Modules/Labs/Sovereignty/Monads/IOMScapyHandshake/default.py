"""IOMScapyHandshake — Effectful: Auth capture (live traffic)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-scapy-handshake", help="Auth capture (live traffic)")

@app.command()
def run() -> None:
    """Auth capture (live traffic). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Auth capture (live traffic)")

if __name__ == "__main__":
    app()
