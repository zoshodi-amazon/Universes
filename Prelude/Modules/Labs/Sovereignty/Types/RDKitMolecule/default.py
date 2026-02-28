"""RDKitMolecule — Molecular structure artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class MolFormat(str, Enum):
    sdf = "sdf"; mol2 = "mol2"; pdb = "pdb"; smiles = "smiles"
class Molecule(BaseModel):
    atoms: int = Field(default=10, ge=1, le=10000)
    bonds: int = Field(default=10, ge=0, le=10000)
    charge: int = Field(default=0, ge=-10, le=10)
    format: MolFormat = MolFormat.sdf
