-- Types/Dependent/ContainerConfig/Default.lean
-- [Liquid Crystal] Container configuration — parameterized by ContainerBackend.

import Lean.Data.Json
import Types.Inductive.ContainerBackend.Default

/-- Container configuration — parameterized by ContainerBackend. -/
structure ContainerConfig where
  enable : Bool := false
  backend : ContainerBackend := .podman
  deriving Repr, Lean.ToJson, Lean.FromJson
