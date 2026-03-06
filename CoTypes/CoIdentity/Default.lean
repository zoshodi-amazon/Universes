-- CoTypes/CoIdentity/Default.lean
-- Coalgebraic dual of Types/Identity/ — Coterminal objects.
-- Where Identity types have exactly one canonical inhabitant (constructors),
-- CoIdentity types define introspection witnesses: what can be observed
-- about a terminal object (installed? present? reachable?).
-- Duality: Terminal ↔ Coterminal

import Lean.Data.Json

/-- Observation witness for a Nix store package — is it installed? -/
structure CoPackage where
  name : String
  installed : Bool := false
  storePathExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation witness for a program — is it reachable on PATH? -/
structure CoProgramConfig where
  name : String
  reachable : Bool := false
  storePathExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation witness for a phase — did it execute? Are outputs present? -/
structure CoPhase where
  name : String
  inputsResolved : Bool := false
  outputsPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
