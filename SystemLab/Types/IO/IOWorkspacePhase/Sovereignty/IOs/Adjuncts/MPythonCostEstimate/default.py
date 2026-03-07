"""MPythonCostEstimate — Pure procurement cost breakdown

Deterministic: same config -> same cost breakdown.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-costestimate", help="Procurement cost breakdown")

TIERS = {
    "tier1": ["energy", "water", "food", "shelter"],
    "tier2": ["medical", "comms", "compute"],
    "tier3": ["intelligence", "defense"],
    "tier4": ["transport", "trade", "fabrication"],
}


@app.command()
def costestimate(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH")] = Path("default.json"),
    scope: Annotated[str, typer.Option(help="all | needed | acquired")] = "all",
) -> None:
    """Cost breakdown by domain."""
    cfg = json.loads(config.read_text()) if config.exists() else {}
    all_domains = [d for tier in TIERS.values() for d in tier]

    total = 0.0
    typer.echo("=== Cost Estimate ===")
    for domain in all_domains:
        items = _collect_items(cfg.get(domain, {}))
        if scope == "needed":
            items = [i for i in items if i.get("lifecycle", {}).get("status") not in ("acquired", "tested", "deployed")]
        elif scope == "acquired":
            items = [i for i in items if i.get("lifecycle", {}).get("status") in ("acquired", "tested", "deployed")]
        cost = sum(i.get("physical", {}).get("unit_cost", {}).get("value", 0) * i.get("identity", {}).get("qty", 1) for i in items)
        if cost > 0:
            typer.echo(f"  {domain}: ${cost:.2f}")
        total += cost
    typer.echo(f"\n  TOTAL: ${total:.2f}")


def _collect_items(cfg: dict) -> list[dict]:
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
