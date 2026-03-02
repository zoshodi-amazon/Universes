"""MPythonDialogTree — Pure Dialog tree generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-dialogtree", help="Dialog tree generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Dialog tree from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Dialog tree -> {output}")

if __name__ == "__main__":
    app()
