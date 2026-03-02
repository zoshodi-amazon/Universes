"""IOMMoneroWallet — Effectful: Wallet operations (real keys)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-monero-wallet", help="Wallet operations (real keys)")

@app.command()
def run() -> None:
    """Wallet operations (real keys). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Wallet operations (real keys)")

if __name__ == "__main__":
    app()
