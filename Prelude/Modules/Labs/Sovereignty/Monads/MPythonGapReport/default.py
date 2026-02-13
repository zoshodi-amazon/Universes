"""MPythonGapReport — Pure capability gap analysis

Deterministic: same config -> same gap report.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-gapreport", help="Capability gap analysis")

TIERS = {
    "tier1": ["energy", "water", "food", "shelter"],
    "tier2": ["medical", "comms", "compute"],
    "tier3": ["intelligence", "defense"],
    "tier4": ["transport", "trade", "fabrication"],
}


@app.command()
def gapreport(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH")] = Path("default.json"),
    scope: Annotated[str, typer.Option(help="all | tier1 | tier2 | tier3 | tier4")] = "all",
) -> None:
    """Report capability gaps — domains with no items."""
    cfg = json.loads(config.read_text()) if config.exists() else {}

    domains = TIERS.get(scope, [d for tier in TIERS.values() for d in tier])
    gaps: list[tuple[str, str]] = []

    for domain in domains:
        dcfg = cfg.get(domain, {})
        items = _collect_items(dcfg)
        if not items:
            gaps.append((domain, "no items"))
        else:
            untrained = [i for i in items if i.get("lifecycle", {}).get("competency") in ("untrained", "novice")]
            if untrained:
                gaps.append((domain, f"{len(untrained)} untrained"))

    typer.echo(f"=== Gap Report ({len(gaps)} gaps) ===")
    for domain, reason in gaps:
        tier = next((t for t, ds in TIERS.items() if domain in ds), "?")
        typer.echo(f"  [ ] {tier}/{domain}: {reason}")

    if not gaps:
        typer.echo("  All capabilities covered.")


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
