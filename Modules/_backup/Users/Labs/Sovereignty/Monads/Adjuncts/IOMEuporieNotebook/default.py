"""IOMEuporieNotebook — Effectful: Interactive notebook session"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-euporie-notebook", help="Interactive notebook session")

@app.command()
def run() -> None:
    """Interactive notebook session. Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Interactive notebook session")

if __name__ == "__main__":
    app()
