"""MPythonReaction — Pure Chemical reaction generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-reaction", help="Chemical reaction generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Chemical reaction from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Chemical reaction -> {output}")

if __name__ == "__main__":
    app()
