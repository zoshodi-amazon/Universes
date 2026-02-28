"""IOMMoneroTransaction — Effectful: Transaction signing (blockchain)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-monero-transaction", help="Transaction signing (blockchain)")

@app.command()
def run() -> None:
    """Transaction signing (blockchain). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Transaction signing (blockchain)")

if __name__ == "__main__":
    app()
