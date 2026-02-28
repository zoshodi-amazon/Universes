"""MPythonMix — Pure Audio mix generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-mix", help="Audio mix generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Audio mix from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Audio mix -> {output}")

if __name__ == "__main__":
    app()
