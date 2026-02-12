-- Sovereignty/Json.lean — FromJson instances for config deserialization
-- Reads Nix-serialized JSON (Env/default.json) into the ADT
import Sovereignty.Types
import Lean.Data.Json

open Lean Json

-- =============================================================================
-- ENUM HELPERS
-- =============================================================================

private def enumFromStr (map : List (String × α)) (s : String) (default : α) : α :=
  match map.find? (fun (k, _) => k == s) with
  | some (_, v) => v
  | none => default

-- =============================================================================
-- GLOBAL
-- =============================================================================

instance : FromJson Mode where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("nomadic", .nomadic), ("urban", .urban), ("base", .base)] s .base

instance : FromJson Bootstrap where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("knowledge", .knowledge), ("energy", .energy), ("compute", .compute)] s .knowledge

instance : FromJson FabTier where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("assembly", .assembly), ("component", .component), ("material", .material)] s .assembly

-- =============================================================================
-- OPSEC
-- =============================================================================

instance : FromJson ThermalSig where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("unmanaged", .unmanaged), ("passive", .passive), ("active", .active)] s .unmanaged

instance : FromJson AcousticSig where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("unmanaged", .unmanaged), ("dampened", .dampened), ("silent", .silent)] s .unmanaged

instance : FromJson VisualSig where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("visible", .visible), ("camouflaged", .camouflaged), ("concealed", .concealed)] s .visible

instance : FromJson ElectronicSig where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("tracked", .tracked), ("minimal", .minimal), ("dark", .dark)] s .minimal

instance : FromJson FinancialSig where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("traceable", .traceable), ("pseudonymous", .pseudonymous), ("anonymous", .anonymous)] s .traceable

instance : FromJson Signature where
  fromJson? j := do
    return {
      thermal := (j.getObjValAs? ThermalSig "thermal").toOption.getD default
      acoustic := (j.getObjValAs? AcousticSig "acoustic").toOption.getD default
      visual := (j.getObjValAs? VisualSig "visual").toOption.getD default
      electronic := (j.getObjValAs? ElectronicSig "electronic").toOption.getD default
      financial := (j.getObjValAs? FinancialSig "financial").toOption.getD default
    }

instance : FromJson Opsec where
  fromJson? j := do
    return {
      physical := (j.getObjValAs? Bool "physical").toOption.getD true
      signal := (j.getObjValAs? Bool "signal").toOption.getD true
      digital := (j.getObjValAs? Bool "digital").toOption.getD true
      social := (j.getObjValAs? Bool "social").toOption.getD false
      financial := (j.getObjValAs? Bool "financial").toOption.getD true
      temporal := (j.getObjValAs? Bool "temporal").toOption.getD false
      legal := (j.getObjValAs? Bool "legal").toOption.getD false
    }

-- =============================================================================
-- COMPETENCY + ACQUISITION
-- =============================================================================

instance : FromJson Competency where
  fromJson? j := do let s ← j.getStr?; return enumFromStr
    [("untrained", .untrained), ("novice", .novice), ("intermediate", .intermediate),
     ("proficient", .proficient), ("expert", .expert)] s .untrained

instance : FromJson AcqStatus where
  fromJson? j := do let s ← j.getStr?; return enumFromStr
    [("needed", .needed), ("sourced", .sourced), ("ordered", .ordered),
     ("acquired", .acquired), ("tested", .tested), ("deployed", .deployed)] s .needed

instance : FromJson SourceType where
  fromJson? j := do let s ← j.getStr?; return enumFromStr
    [("diy", .diy), ("salvage", .salvage), ("trade", .trade)] s .diy

-- =============================================================================
-- UNITS
-- =============================================================================

instance : FromJson MassUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("g", .g), ("kg", .kg)] s .g
instance : FromJson VolumeUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("mL", .mL), ("L", .L)] s .L
instance : FromJson TimeUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("s", .s), ("min", .min), ("hr", .hr)] s .min
instance : FromJson PowerUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("mW", .mW), ("W", .W), ("kW", .kW)] s .W
instance : FromJson EnergyUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("Wh", .Wh), ("kWh", .kWh)] s .Wh
instance : FromJson DistUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("m", .m), ("km", .km)] s .m
instance : FromJson CapacityUnit where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("mL", .mL), ("L", .L), ("gal", .gal)] s .L
instance : FromJson Currency where
  fromJson? j := do let s ← j.getStr?; return enumFromStr [("USD", .USD), ("EUR", .EUR), ("XMR", .XMR), ("BTC", .BTC), ("none", .none)] s .USD

instance : FromJson Mass where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? MassUnit "unit").toOption.getD .g }
instance : FromJson Vol where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? VolumeUnit "unit").toOption.getD .L }
instance : FromJson Duration where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? TimeUnit "unit").toOption.getD .min }
instance : FromJson Pow where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? PowerUnit "unit").toOption.getD .W }
instance : FromJson EnergyQty where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? EnergyUnit "unit").toOption.getD .Wh }
instance : FromJson Dist where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? DistUnit "unit").toOption.getD .m }
instance : FromJson Cap where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, unit := (j.getObjValAs? CapacityUnit "unit").toOption.getD .L }
instance : FromJson Cost where
  fromJson? j := do return { value := (j.getObjValAs? Float "value").toOption.getD 0.0, currency := (j.getObjValAs? Currency "currency").toOption.getD .USD }
