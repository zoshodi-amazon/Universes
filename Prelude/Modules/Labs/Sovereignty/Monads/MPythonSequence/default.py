"""MPythonSequence — Pure Frame sequence generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-sequence", help="Frame sequence generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Frame sequence from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Frame sequence -> {output}")

if __name__ == "__main__":
    app()
