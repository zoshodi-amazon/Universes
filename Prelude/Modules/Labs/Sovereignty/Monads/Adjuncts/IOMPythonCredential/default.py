"""IOMPythonCredential — Effectful: Credential generation (entropy)"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-python-credential", help="Credential generation (entropy)")

@app.command()
def run() -> None:
    """Credential generation (entropy). Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Credential generation (entropy)")

if __name__ == "__main__":
    app()
