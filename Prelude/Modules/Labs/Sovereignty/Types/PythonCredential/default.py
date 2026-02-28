"""PythonCredential — Generated credential artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class CredType(str, Enum):
    password = "password"; keypair = "keypair"; token = "token"
class Credential(BaseModel):
    cred_type: CredType = CredType.password
    strength_bits: int = Field(default=256, ge=64, le=4096)
    format: str = Field(default="base64", description="base64|hex|raw")
