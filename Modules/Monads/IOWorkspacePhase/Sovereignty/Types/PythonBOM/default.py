"""PythonBOM — Bill of Materials artifact (3 params: scope, format, sort_by)

Includes shared base types: Item, Signature, typed units.
All params bounded with defaults. No nulls. No loose strings.
"""
from enum import Enum
from pydantic import BaseModel, Field


# -- Typed units (value + unit, no raw strings) --

class MassUnit(str, Enum):
    g = "g"
    kg = "kg"

class VolumeUnit(str, Enum):
    mL = "mL"
    L = "L"

class TimeUnit(str, Enum):
    s = "s"
    min = "min"
    hr = "hr"

class Currency(str, Enum):
    USD = "USD"
    EUR = "EUR"
    XMR = "XMR"
    BTC = "BTC"

class Mass(BaseModel):
    value: float = Field(default=0.0, ge=0.0)
    unit: MassUnit = MassUnit.g

class Vol(BaseModel):
    value: float = Field(default=0.0, ge=0.0)
    unit: VolumeUnit = VolumeUnit.L

class Duration(BaseModel):
    value: float = Field(default=0.0, ge=0.0)
    unit: TimeUnit = TimeUnit.min

class Cost(BaseModel):
    value: float = Field(default=0.0, ge=0.0)
    currency: Currency = Currency.USD


# -- Signature (5 params) --

class ThermalSig(str, Enum):
    unmanaged = "unmanaged"
    passive = "passive"
    active = "active"

class AcousticSig(str, Enum):
    unmanaged = "unmanaged"
    dampened = "dampened"
    silent = "silent"

class VisualSig(str, Enum):
    visible = "visible"
    camouflaged = "camouflaged"
    concealed = "concealed"

class ElectronicSig(str, Enum):
    tracked = "tracked"
    minimal = "minimal"
    dark = "dark"

class FinancialSig(str, Enum):
    traceable = "traceable"
    pseudonymous = "pseudonymous"
    anonymous = "anonymous"

class Signature(BaseModel):
    thermal: ThermalSig = ThermalSig.unmanaged
    acoustic: AcousticSig = AcousticSig.unmanaged
    visual: VisualSig = VisualSig.visible
    electronic: ElectronicSig = ElectronicSig.minimal
    financial: FinancialSig = FinancialSig.traceable


# -- Competency + Acquisition --

class Competency(str, Enum):
    untrained = "untrained"
    novice = "novice"
    intermediate = "intermediate"
    proficient = "proficient"
    expert = "expert"

class AcqStatus(str, Enum):
    needed = "needed"
    sourced = "sourced"
    ordered = "ordered"
    acquired = "acquired"
    tested = "tested"
    deployed = "deployed"

class SourceType(str, Enum):
    diy = "diy"
    salvage = "salvage"
    trade = "trade"
    url = "url"
    local = "local"


# -- Item (3 sub-artifacts composed) --

class ItemIdentity(BaseModel):
    name: str
    model: str
    qty: int = Field(default=1, ge=1)

class ItemPhysical(BaseModel):
    unit_cost: Cost = Field(default_factory=Cost)
    weight: Mass = Field(default_factory=Mass)
    volume: Vol = Field(default_factory=Vol)
    pack_time: Duration = Field(default_factory=Duration)

class ItemStatus(BaseModel):
    source: SourceType = SourceType.diy
    status: AcqStatus = AcqStatus.needed
    competency: Competency = Competency.untrained
    signature: Signature = Field(default_factory=Signature)

class Item(BaseModel):
    identity: ItemIdentity
    physical: ItemPhysical = Field(default_factory=ItemPhysical)
    lifecycle: ItemStatus = Field(default_factory=ItemStatus)


# -- BOM artifact (3 params) --

class BOMScope(str, Enum):
    all = "all"
    acquired = "acquired"
    needed = "needed"

class BOMFormat(str, Enum):
    json = "json"
    csv = "csv"
    table = "table"

class BOMSortBy(str, Enum):
    name = "name"
    cost = "cost"
    weight = "weight"
    status = "status"

class BOM(BaseModel):
    scope: BOMScope = BOMScope.all
    format: BOMFormat = BOMFormat.table
    sort_by: BOMSortBy = BOMSortBy.name
