"""MFFmpegVideoClip — Pure Video render generation"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="ffmpeg-videoclip", help="Video render generation")

@app.command()
def run(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out"),
) -> None:
    """Generate Video render from bounded params."""
    # TODO: wire to engine
    typer.echo(f"Video render -> {output}")

if __name__ == "__main__":
    app()
