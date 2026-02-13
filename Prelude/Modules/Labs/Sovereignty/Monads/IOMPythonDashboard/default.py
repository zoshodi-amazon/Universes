"""IOMPythonDashboard — Effectful: Live TUI dashboard"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="io-python-dashboard", help="Live TUI dashboard")

@app.command()
def run() -> None:
    """Live TUI dashboard. Effectful: requires interaction/network/entropy."""
    # TODO: wire to engine
    typer.echo("Live TUI dashboard")

if __name__ == "__main__":
    app()
