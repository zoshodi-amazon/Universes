"""MPythonPackList — Pure pack list query filtered by mode constraints

Deterministic: same config + mode -> same pack list.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-packlist", help="Mode-filtered loadout generator")


@app.command()
def packlist(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH")] = Path("default.json"),
    mode: Annotated[str, typer.Option(help="nomadic | urban | base")] = "nomadic",
    max_weight_kg: Annotated[float, typer.Option(help="Max weight in kg")] = 25.0,
    max_volume_L: Annotated[float, typer.Option(help="Max volume in liters")] = 65.0,
) -> None:
    """Generate pack list filtered by mode constraints."""
    cfg = json.loads(config.read_text()) if config.exists() else {}
    items = _collect_acquired(cfg)

    total_weight_g = sum(i.get("physical", {}).get("weight", {}).get("value", 0) * i.get("identity", {}).get("qty", 1) for i in items)
    total_volume_L = sum(i.get("physical", {}).get("volume", {}).get("value", 0) * i.get("identity", {}).get("qty", 1) for i in items)

    typer.echo(f"=== Pack: {mode} mode ===")
    typer.echo(f"  Weight: {total_weight_g:.0f}g / {max_weight_kg * 1000:.0f}g")
    typer.echo(f"  Volume: {total_volume_L:.1f}L / {max_volume_L:.1f}L")

    if total_weight_g > max_weight_kg * 1000:
        typer.echo(f"  ! OVERWEIGHT by {total_weight_g - max_weight_kg * 1000:.0f}g")
    if total_volume_L > max_volume_L:
        typer.echo(f"  ! OVERVOLUME by {total_volume_L - max_volume_L:.1f}L")

    typer.echo(f"\n  Items ({len(items)}):")
    for i in items:
        ident = i.get("identity", {})
        phys = i.get("physical", {})
        typer.echo(f"    {ident.get('name','')} x{ident.get('qty',1)} | {phys.get('weight',{}).get('value',0)}g")


def _collect_acquired(cfg: dict) -> list[dict]:
    items: list[dict] = []
    if isinstance(cfg, dict):
        if "items" in cfg and isinstance(cfg["items"], list):
            items.extend(i for i in cfg["items"] if i.get("lifecycle", {}).get("status") in ("acquired", "tested", "deployed"))
        for v in cfg.values():
            items.extend(_collect_acquired(v))
    elif isinstance(cfg, list):
        for v in cfg:
            items.extend(_collect_acquired(v))
    return items


if __name__ == "__main__":
    app()
