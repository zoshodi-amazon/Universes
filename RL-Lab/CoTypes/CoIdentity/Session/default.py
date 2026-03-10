"""CoRunIdentity [CoIdentity] — Run introspection witness (3 fields). All bounded.

BEC-dual — the coterminal dual of RunIdentity. Witnesses whether the
run context (store, blob dir, DB) is reachable and valid.
"""

from pydantic import BaseModel, Field


class CoRunIdentity(BaseModel):
    """CoRunIdentity [CoIdentity] — Run context reachability witness (3 fields)."""

    store_reachable: bool = Field(
        default=False, description="Whether the StoreMonad DB URL is connectable"
    )
    db_valid: bool = Field(
        default=False,
        description="Whether the artifacts table exists and has correct schema",
    )
    blob_dir_exists: bool = Field(
        default=False,
        description="Whether the blob_dir directory exists on the filesystem",
    )
