"""MoneroTransaction — Signed transaction artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class FeePriority(str, Enum):
    low = "low"; normal = "normal"; elevated = "elevated"
class Transaction(BaseModel):
    coin: str = "xmr"
    amount: float = Field(default=0.0, ge=0.0)
    fee_priority: FeePriority = FeePriority.normal
