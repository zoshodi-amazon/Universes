"""MPythonShader — Pure GPU program generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-shader", help="GPU program generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate GPU program from bounded params."""
    # TODO: wire to engine
    typer.echo(f"GPU program -> {output}")

if __name__ == "__main__":
    app()
