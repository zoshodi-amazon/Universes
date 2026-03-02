"""MPythonAlloy — Pure Material composition generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-alloy", help="Material composition generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Material composition from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Material composition -> {output}")

if __name__ == "__main__":
    app()
