"""MPythonDiagram — Pure Technical diagram generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-diagram", help="Technical diagram generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Technical diagram from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Technical diagram -> {output}")

if __name__ == "__main__":
    app()
