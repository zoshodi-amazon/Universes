"""MPythonPropagation — Pure RF path loss simulation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-propagation", help="RF path loss simulation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.csv"),
) -> None:
    """RF path loss simulation from bounded params."""
    # TODO: wire to engine
    typer.echo(f"RF path loss simulation -> {output}")

if __name__ == "__main__":
    app()
