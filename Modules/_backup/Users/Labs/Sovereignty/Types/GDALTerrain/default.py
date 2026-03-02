"""GDALTerrain — Offline map/elevation artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class TerrainSource(str, Enum):
    osm = "osm"
    srtm = "srtm"
    copernicus = "copernicus"

class TerrainFormat(str, Enum):
    mbtiles = "mbtiles"
    geotiff = "geotiff"
    gpkg = "gpkg"

class Terrain(BaseModel):
    bounds: str = Field(default="0,0,1,1", description="minlon,minlat,maxlon,maxlat")
    zoom: int = Field(default=14, ge=1, le=20)
    source: TerrainSource = TerrainSource.osm
    format: TerrainFormat = TerrainFormat.mbtiles
