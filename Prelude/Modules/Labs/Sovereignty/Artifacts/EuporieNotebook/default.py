"""EuporieNotebook — Terminal notebook session artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class Kernel(str, Enum):
    python = "python"; julia = "julia"
class Theme(str, Enum):
    dark = "dark"; light = "light"
class Notebook(BaseModel):
    kernel: Kernel = Kernel.python
    theme: Theme = Theme.dark
    width: int = Field(default=120, ge=40, le=300)
