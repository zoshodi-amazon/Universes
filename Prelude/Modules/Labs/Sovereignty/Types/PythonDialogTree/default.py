"""PythonDialogTree — Branching narrative artifact (3 params)"""
from pydantic import BaseModel, Field
class DialogTree(BaseModel):
    nodes: int = Field(default=10, ge=1, le=10000)
    branches: int = Field(default=3, ge=1, le=20)
    variables: int = Field(default=0, ge=0, le=100)
