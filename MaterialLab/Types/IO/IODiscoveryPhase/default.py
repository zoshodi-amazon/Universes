"""IODiscoveryPhase [IO] — Material/process discovery and screening, QGP phase.

Reads DiscoveryHom from default.json + CLI overrides. Produces DiscoveryProductOutput + DiscoveryProductMeta.
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
    """IO executor settings for Discovery phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IODiscoveryPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="discover",
    )

    io_sources: list[str] = Field(
        default=["local"],
        min_length=1,
        max_length=10,
        description="Data sources to query for material/process discovery",
    )
    max_results: int = Field(
        default=20,
        ge=1,
        le=1000,
        description="Maximum number of candidate results to return",
    )
    target_method: str = Field(
        default="fdm",
        min_length=1,
        max_length=64,
        description="Target fabrication method to filter candidates (e.g. fdm, sla, sls)",
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
    """Execute the Discovery phase."""
    raise NotImplementedError("IODiscoveryPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
