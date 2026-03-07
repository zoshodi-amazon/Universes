"""IOGeometryPhase [IO] — Parametric geometry generation and export, QGP phase.

Reads GeometryHom from default.json + CLI overrides. Produces GeometryProductOutput + GeometryProductMeta.
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
    """IO executor settings for Geometry phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOGeometryPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="geometry",
    )

    io_script_path: str = Field(
        default="",
        max_length=4096,
        description="Path to the CadQuery or OpenSCAD geometry script",
    )
    operation: str = Field(
        default="build",
        min_length=1,
        max_length=64,
        description="Geometry operation to perform (e.g. build, boolean, fillet)",
    )
    export_format: str = Field(
        default="step",
        min_length=1,
        max_length=16,
        description="Export format for the generated geometry (e.g. step, stl, 3mf)",
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
    """Execute the Geometry phase."""
    raise NotImplementedError("IOGeometryPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
