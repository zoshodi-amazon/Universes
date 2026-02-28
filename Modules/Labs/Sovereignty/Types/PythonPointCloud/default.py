"""PythonPointCloud — 3D scan point cloud artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class PointCloudFormat(str, Enum):
    ply = "ply"; pcd = "pcd"; las = "las"
class PointCloud(BaseModel):
    points: int = Field(default=100000, ge=100, le=100_000_000)
    resolution_mm: float = Field(default=1.0, gt=0.0, le=100.0)
    color: bool = True
    format: PointCloudFormat = PointCloudFormat.ply
