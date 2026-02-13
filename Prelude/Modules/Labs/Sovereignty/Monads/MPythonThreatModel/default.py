"""MPythonThreatModel — Pure signature exposure assessment

Deterministic: same config + mode -> same threat assessment.
"""
import json
from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(name="python-threatmodel", help="Signature exposure assessment")

WORST = {
    "thermal": ["active", "passive", "unmanaged"],
    "acoustic": ["unmanaged", "dampened", "silent"],
    "visual": ["visible", "camouflaged", "concealed"],
    "electronic": ["tracked", "minimal", "dark"],
    "financial": ["traceable", "pseudonymous", "anonymous"],
}


@app.command()
def threatmodel(
    config: Annotated[Path, typer.Option(envvar="SOV_CONFIG_PATH")] = Path("default.json"),
    mode: Annotated[str, typer.Option(help="nomadic | urban | base")] = "nomadic",
) -> None:
    """Assess OPSEC signature exposure across all domains."""
    cfg = json.loads(config.read_text()) if config.exists() else {}
    sigs = _collect_signatures(cfg)

    typer.echo(f"=== Threat Model ({mode} mode, {len(sigs)} signatures) ===")
    aggregate: dict[str, str] = {}
    for layer, ordering in WORST.items():
        worst_idx = len(ordering) - 1
        for sig in sigs:
            val = sig.get(layer, ordering[-1])
            if val in ordering:
                worst_idx = min(worst_idx, ordering.index(val))
        aggregate[layer] = ordering[worst_idx] if ordering else "unknown"

    for layer, level in aggregate.items():
        mark = "!" if level == WORST[layer][0] else "~" if level == WORST[layer][1] else "."
        typer.echo(f"  [{mark}] {layer}: {level}")


def _collect_signatures(cfg: dict) -> list[dict]:
    sigs: list[dict] = []
    if isinstance(cfg, dict):
        if "signature" in cfg and isinstance(cfg["signature"], dict):
            sigs.append(cfg["signature"])
        for v in cfg.values():
            sigs.extend(_collect_signatures(v))
    elif isinstance(cfg, list):
        for v in cfg:
            sigs.extend(_collect_signatures(v))
    return sigs


if __name__ == "__main__":
    app()
