"""PythonIcon — UI/symbol asset artifact (3 params)"""
from pydantic import BaseModel, Field
class Icon(BaseModel):
    size_px: int = Field(default=24, ge=8, le=512)
    palette_colors: int = Field(default=2, ge=1, le=256)
    padding_px: int = Field(default=2, ge=0, le=32)
