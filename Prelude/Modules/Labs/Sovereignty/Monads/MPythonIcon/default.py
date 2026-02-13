"""MPythonIcon — Pure UI/symbol asset generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-icon", help="UI/symbol asset generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate UI/symbol asset from bounded params."""
    # TODO: wire to engine
    typer.echo(f"UI/symbol asset -> {output}")

if __name__ == "__main__":
    app()
