"""CoStoreComonad [Comonad] — Observation witness for StoreMonad (5 fields).

Plasma-dual phase — the coalgebraic dual of StoreMonad.
Where StoreMonad manages artifact persistence (put/get/latest),
CoStoreComonad witnesses the observed state of the store after the fact.

extract(CoStoreComonad) -> artifact_count (current observation summary)
extend(f)(cs)           -> new CoStoreComonad after applying observation function f

Fields satisfy Independence, Completeness, Locality:
- db_reachable:     whether the DB connection was successfully established
- artifact_count:   total artifacts observed in the store — independent counter
- blob_dir_exists:  whether the blob directory exists on the filesystem
- latest_created:   ISO timestamp of the most recently created artifact
- disk_usage_mb:    total disk usage of blob directory in megabytes
"""

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class CoStoreComonad(BaseModel):
    """CoStoreComonad [Comonad] — Observation witness for artifact store state (5 fields)."""

    db_reachable: bool = Field(
        default=False,
        description="Whether the SQLite/DB connection was successfully probed",
    )
    artifact_count: int = Field(
        default=0,
        ge=0,
        le=10_000_000,
        description="Total artifact rows observed in the store",
    )
    blob_dir_exists: bool = Field(
        default=False, description="Whether the blob directory exists on the filesystem"
    )
    latest_created: Annotated[str, StringConstraints(max_length=32)] = Field(
        default="",
        description="ISO timestamp of most recently created artifact — empty if store is empty",
    )
    disk_usage_mb: float = Field(
        default=0.0,
        ge=0.0,
        le=1e9,
        description="Total disk usage of blob directory in megabytes",
    )
