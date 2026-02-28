"""MPythonBOM — Pure BOM query over the sovereignty type space

Deterministic: same config -> same BOM output.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-bom", help="Bill of materials query")


@app.command()
def bom(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH", help="Path to sovereignty config JSON")] = Path("default.json"),
    scope: Annotated[str, typer.Option(help="all | acquired | needed")] = "all",
    format: Annotated[str, typer.Option(help="table | json | csv")] = "table",
    sort_by: Annotated[str, typer.Option(help="name | cost | weight | status")] = "name",
) -> None:
    """Generate bill of materials from sovereignty config."""
    cfg = json.loads(config.read_text()) if config.exists() else {}
    items = _collect_items(cfg)

    if scope == "acquired":
        items = [i for i in items if i.get("lifecycle", {}).get("status") in ("acquired", "tested", "deployed")]
    elif scope == "needed":
        items = [i for i in items if i.get("lifecycle", {}).get("status") not in ("acquired", "tested", "deployed")]

    items.sort(key=lambda i: i.get("identity", {}).get(sort_by, i.get("identity", {}).get("name", "")))

    if format == "json":
        typer.echo(json.dumps(items, indent=2))
    elif format == "csv":
        typer.echo("name,model,qty,cost,weight,status")
        for i in items:
            ident = i.get("identity", {})
            phys = i.get("physical", {})
            life = i.get("lifecycle", {})
            typer.echo(f"{ident.get('name','')},{ident.get('model','')},{ident.get('qty',1)},{phys.get('unit_cost',{}).get('value',0)},{phys.get('weight',{}).get('value',0)},{life.get('status','needed')}")
    else:
        total_cost = sum(i.get("physical", {}).get("unit_cost", {}).get("value", 0) * i.get("identity", {}).get("qty", 1) for i in items)
        total_weight = sum(i.get("physical", {}).get("weight", {}).get("value", 0) * i.get("identity", {}).get("qty", 1) for i in items)
        typer.echo(f"=== BOM ({len(items)} items) ===")
        for i in items:
            ident = i.get("identity", {})
            phys = i.get("physical", {})
            life = i.get("lifecycle", {})
            mark = "[x]" if life.get("status") in ("acquired", "tested", "deployed") else "[ ]"
            typer.echo(f"  {mark} {ident.get('name','')} ({ident.get('model','')}) x{ident.get('qty',1)} | {phys.get('weight',{}).get('value',0)}{phys.get('weight',{}).get('unit','g')} | {phys.get('unit_cost',{}).get('currency','USD')} {phys.get('unit_cost',{}).get('value',0)} | {life.get('status','needed')}")
        typer.echo(f"\n  Total: {len(items)} items | ${total_cost:.2f} | {total_weight:.0f}g")


def _collect_items(cfg: dict) -> list[dict]:
    """Walk the config tree and collect all items lists."""
    items: list[dict] = []
    if isinstance(cfg, dict):
        if "items" in cfg and isinstance(cfg["items"], list):
            items.extend(cfg["items"])
        for v in cfg.values():
            items.extend(_collect_items(v))
    elif isinstance(cfg, list):
        for v in cfg:
            items.extend(_collect_items(v))
    return items


if __name__ == "__main__":
    app()
