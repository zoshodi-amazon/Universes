"""MNmapTopology — Pure network topology graph from scan params"""
from pathlib import Path
from typing import Annotated
import typer

app = typer.Typer(name="nmap-topology", help="Network topology graph")

@app.command()
def topology(
    output: Annotated[Path, typer.Option(help="Output file")] = Path("out.json"),
    scan_range: Annotated[str, typer.Option(help="CIDR range")] = "192.168.1.0/24",
    depth: Annotated[int, typer.Option(help="Traceroute depth")] = 2,
) -> None:
    """Generate network topology graph from nmap scan."""
    typer.echo(f"Topology {scan_range} depth={depth} -> {output}")

if __name__ == "__main__":
    app()
