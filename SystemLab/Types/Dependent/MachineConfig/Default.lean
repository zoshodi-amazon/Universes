-- Types/Dependent/MachineConfig/Default.lean
-- [Liquid Crystal] Machine configuration — parameterized by MachineArch + MachineFormat.

import Lean.Data.Json
import Types.Inductive.MachineArch.Default
import Types.Inductive.MachineFormat.Default

/-- Machine configuration — parameterized by MachineArch + MachineFormat. -/
structure MachineConfig where
  name : String
  hostname : String
  arch : MachineArch := .x86_64
  format : MachineFormat := .vm
  deriving Repr, Lean.ToJson, Lean.FromJson
