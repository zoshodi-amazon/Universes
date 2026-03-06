"""PythonGapReport — Capability holes artifact (2 params)"""
from enum import Enum
from pydantic import BaseModel


class GapScope(str, Enum):
    all = "all"
    tier1 = "tier1"
    tier2 = "tier2"
    tier3 = "tier3"
    tier4 = "tier4"

class GapReport(BaseModel):
    scope: GapScope = GapScope.all
    include_untrained: bool = True
