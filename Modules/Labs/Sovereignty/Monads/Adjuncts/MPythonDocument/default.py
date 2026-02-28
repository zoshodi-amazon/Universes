"""MPythonDocument — Pure Document generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-document", help="Document generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Document from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Document -> {output}")

if __name__ == "__main__":
    app()
