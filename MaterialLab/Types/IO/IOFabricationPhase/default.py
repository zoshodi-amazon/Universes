"""IOFabricationPhase [IO] — Slicing and G-code generation for additive manufacturing, QGP phase.

Reads FabricationHom from default.json + CLI overrides. Produces FabricationProductOutput + FabricationProductMeta.
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
    """IO executor settings for Fabrication phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOFabricationPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="fabrication",
    )

    io_slicer: str = Field(
        default="cura",
        min_length=1,
        max_length=64,
        description="Slicer engine to use for toolpath generation (e.g. cura, prusaslicer, orcaslicer)",
    )
    support_enabled: bool = Field(
        default=True,
        description="Whether to generate support structures in the sliced output",
    )
    output_format: str = Field(
        default="gcode",
        min_length=1,
        max_length=16,
        description="Output format for the fabrication toolpath (e.g. gcode, 3mf, ufp)",
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
    """Execute the Fabrication phase."""
    raise NotImplementedError("IOFabricationPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
