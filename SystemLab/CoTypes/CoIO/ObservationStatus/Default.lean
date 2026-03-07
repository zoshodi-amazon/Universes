-- CoTypes/CoIO/ObservationStatus/Default.lean
-- CoIO — observation status for a single phase observer.

import Lean.Data.Json

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
