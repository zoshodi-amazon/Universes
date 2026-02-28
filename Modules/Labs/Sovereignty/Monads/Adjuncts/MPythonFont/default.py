"""MPythonFont — Pure Typeface generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-font", help="Typeface generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Typeface from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Typeface -> {output}")

if __name__ == "__main__":
    app()
