-- CoTypes/CoIO/Default.lean
-- Coalgebraic dual of Types/IO/ — Observer executors.
-- Where IO executors produce system state (catamorphic),
-- CoIO observers probe system state and compare against expectations (anamorphic).
-- Duality: Executors ↔ Observers
--
-- CoIO observer result types. These are populated by the CoIO Nix executor
-- scripts in CoTypes/CoIO/CoIO{Phase}Phase/default.nix.

import Lean.Data.Json
import CoTypes.CoProduct.Default
import CoTypes.Comonad.Default

/-- Observation status for a single phase observer. -/
inductive ObservationStatus where
  | pass
  | fail
  | skip
  | error
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson ObservationStatus where
  toJson
    | .pass => "pass"
    | .fail => "fail"
    | .skip => "skip"
    | .error => "error"

instance : Lean.FromJson ObservationStatus where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "pass" => pure .pass
    | "fail" => pure .fail
    | "skip" => pure .skip
    | "error" => pure .error
    | _ => throw s!"unknown ObservationStatus: {s}"

/-- Result of a single phase observation.
    The primary output type for all CoIO executors. -/
structure ObservationResult where
  phase : String
  status : ObservationStatus := .skip
  schemaValid : Bool := false       -- path (a): schema observation
  runtimeValid : Bool := false      -- path (b): runtime observation
  pathsClosed : Bool := false       -- agreement between (a) and (b)
  message : String := ""
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Aggregate observation across all 7 phases. -/
structure ObservationSummary where
  results : List ObservationResult := []
  totalPhases : Nat := 7
  passCount : Nat := 0
  failCount : Nat := 0
  skipCount : Nat := 0
  allPathsClosed : Bool := false
  trace : Option ObservationTrace := none
  deriving Repr, Lean.ToJson, Lean.FromJson
