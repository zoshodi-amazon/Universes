"""PythonFont — Typeface artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class FontFormat(str, Enum):
    otf = "otf"; ttf = "ttf"; woff2 = "woff2"
class FontWeight(str, Enum):
    thin = "thin"; regular = "regular"; bold = "bold"; black = "black"
class Font(BaseModel):
    family: str = Field(default="monospace", description="Font family name")
    weight: FontWeight = FontWeight.regular
    format: FontFormat = FontFormat.otf
