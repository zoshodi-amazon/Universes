"""MPythonTexture — Pure Surface/material map generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-texture", help="Surface/material map generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Surface/material map from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Surface/material map -> {output}")

if __name__ == "__main__":
    app()
