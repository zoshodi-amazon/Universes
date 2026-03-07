"""DesignIdentity [Identity] — terminal object, BEC phase.

Terminal object for a single design in the MaterialLab type universe.
Uniquely identifies a design artifact by name, version, author, and
manufacturing targets. No optional fields; sentinels used where absence
must be representable.
"""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


class DesignIdentity(BaseModel):
    """Terminal identity for a single design artifact."""

    io_name: Annotated[str, StringConstraints(min_length=1, max_length=128)] = Field(
        description="Design name, e.g. 'cyberdeck-shell-v1'."
    )
    version: Annotated[str, StringConstraints(min_length=1, max_length=20)] = Field(
        description="Semantic version string, e.g. '0.1.0'."
    )
    author: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        description="Operator or author name."
    )
    target_method: Annotated[str, StringConstraints(min_length=1, max_length=20)] = (
        Field(
            description="Manufacturing method reference (ManufMethodInductive), e.g. 'fdm'."
        )
    )
    target_material: Annotated[str, StringConstraints(min_length=1, max_length=20)] = (
        Field(
            description="Material class reference (MaterialClassInductive), e.g. 'petg'."
        )
    )
    io_source: Annotated[str, StringConstraints(min_length=1, max_length=32)] = Field(
        description="Design source: 'local' | 'thingiverse' | 'grabcad' | 'parametric'."
    )
