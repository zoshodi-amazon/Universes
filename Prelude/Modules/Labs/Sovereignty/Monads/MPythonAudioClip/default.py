"""MPythonAudioClip — Pure Audio clip generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="python-audioclip", help="Audio clip generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Audio clip from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Audio clip -> {output}")

if __name__ == "__main__":
    app()
