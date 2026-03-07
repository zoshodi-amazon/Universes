"""[Inductive] — Mesh data structural validation, Crystalline phase."""

from typing import Any

from pydantic import BaseModel, Field


class MeshDataInductive(BaseModel):
    """Validated mesh geometry data. External data enters via from_trimesh."""

    vertex_count: int = Field(
        description="Number of vertices in the mesh",
        ge=3,
        le=100_000_000,
    )
    face_count: int = Field(
        description="Number of faces in the mesh",
        ge=1,
        le=100_000_000,
    )
    is_watertight: bool = Field(
        description="Mesh is closed with no holes",
    )
    volume_m3: float = Field(
        description="Mesh volume in cubic meters",
        ge=0.0,
        le=1000.0,
    )
    surface_area_m2: float = Field(
        description="Surface area in square meters",
        ge=0.0,
        le=10000.0,
    )
    bounding_box_mm: str = Field(
        description="Bounding box in WxHxD format e.g. 100.0x50.0x30.0",
        min_length=5,
        max_length=64,
    )

    @classmethod
    def from_trimesh(cls, mesh: Any) -> "MeshDataInductive":
        """Construct from a trimesh.Trimesh object.

        Import is deferred to keep the type definition pure.
        """
        import trimesh  # noqa: F811

        if not isinstance(mesh, trimesh.Trimesh):
            msg = f"Expected trimesh.Trimesh, got {type(mesh).__name__}"
            raise TypeError(msg)

        extents = mesh.bounding_box.extents
        bounding_box_mm = f"{extents[0]:.1f}x{extents[1]:.1f}x{extents[2]:.1f}"

        return cls(
            vertex_count=len(mesh.vertices),
            face_count=len(mesh.faces),
            is_watertight=bool(mesh.is_watertight),
            volume_m3=float(mesh.volume) if mesh.is_watertight else 0.0,
            surface_area_m2=float(mesh.area),
            bounding_box_mm=bounding_box_mm,
        )
