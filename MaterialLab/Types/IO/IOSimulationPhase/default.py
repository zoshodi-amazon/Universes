"""IOSimulationPhase [IO] — FEA/structural simulation execution, QGP phase.

Reads SimulationHom from default.json + CLI overrides. Produces SimulationProductOutput + SimulationProductMeta.
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
    """IO executor settings for Simulation phase."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOSimulationPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="simulation",
    )

    load_case: str = Field(
        default="static",
        min_length=1,
        max_length=64,
        description="Type of load case to simulate (e.g. static, modal, thermal)",
    )
    force_n: float = Field(
        default=100.0,
        ge=0.0,
        le=1e9,
        description="Applied force magnitude in Newtons",
    )
    include_gravity: bool = Field(
        default=True,
        description="Whether to include gravitational body force in the simulation",
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
    """Execute the Simulation phase."""
    raise NotImplementedError("IOSimulationPhase not yet implemented")


if __name__ == "__main__":
    settings = Settings()
    run(settings)
