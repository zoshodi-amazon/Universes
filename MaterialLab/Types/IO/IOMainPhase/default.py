"""IOMainPhase [IO] — Full MaterialLab pipeline orchestration, QGP phase.

Reads MainHom from default.json + CLI overrides. Produces MainProductOutput + MainProductMeta.
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
    """IO executor settings for Main phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOMainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="main",
    )

    io_design: str = Field(
        ...,
        min_length=1,
        max_length=4096,
        description="Path or identifier for the design to process through the pipeline",
    )
    skip_simulation: bool = Field(
        default=False,
        description="Whether to skip the FEA simulation phase",
    )
    dry_run: bool = Field(
        default=False,
        description="Whether to execute in dry-run mode without producing artifacts",
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
    """Execute the Main phase — full pipeline orchestration."""
    raise NotImplementedError("IOMainPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
