"""IOIngestPhase [IO] — Mesh/CAD file ingestion and validation, QGP phase.

Reads IngestHom from default.json + CLI overrides. Produces IngestProductOutput + IngestProductMeta.
"""

from __future__ import annotations

import sys
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)


class Settings(BaseSettings):
    """IO executor settings for Ingest phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOIngestPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ingest",
    )

    io_file_path: str = Field(
        default="",
        max_length=4096,
        description="Path to the mesh or CAD file to ingest",
    )
    validate_mesh: bool = Field(
        default=True,
        description="Whether to run mesh validation checks on ingest",
    )
    repair_mesh: bool = Field(
        default=False,
        description="Whether to attempt automatic mesh repair on ingest",
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource

        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


def run(settings: Settings) -> None:
    """Execute the Ingest phase."""
    raise NotImplementedError("IOIngestPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
