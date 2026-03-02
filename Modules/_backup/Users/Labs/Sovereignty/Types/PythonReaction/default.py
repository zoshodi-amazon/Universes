"""PythonReaction — Chemical pathway artifact (3 params)"""
from pydantic import BaseModel, Field
class Reaction(BaseModel):
    reactants: int = Field(default=2, ge=1, le=20)
    products: int = Field(default=1, ge=1, le=20)
    temperature_c: float = Field(default=25.0, ge=-273.15, le=3000.0)
