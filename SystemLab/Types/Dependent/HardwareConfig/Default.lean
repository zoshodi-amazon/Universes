-- Types/Dependent/HardwareConfig/Default.lean
-- [Liquid Crystal] Hardware configuration — parameterized by HardwareProfile + GpuDriver + AudioBackend.

import Lean.Data.Json
import Types.Inductive.HardwareProfile.Default
import Types.Inductive.GpuDriver.Default
import Types.Inductive.AudioBackend.Default

/-- Hardware configuration — parameterized by HardwareProfile + GpuDriver + AudioBackend. -/
structure HardwareConfig where
  enable : Bool := false
  profile : HardwareProfile := .generic
  gpu : GpuDriver := .none
  firmware : Bool := true
  audio : AudioBackend := .none
  bluetooth : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
