"""PythonCostEstimate — Procurement cost breakdown artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel


class CostScope(str, Enum):
    all = "all"
    needed = "needed"
    acquired = "acquired"

class CostCurrency(str, Enum):
    USD = "USD"
    EUR = "EUR"

class CostEstimate(BaseModel):
    scope: CostScope = CostScope.all
    currency: CostCurrency = CostCurrency.USD
    include_acquired: bool = True
