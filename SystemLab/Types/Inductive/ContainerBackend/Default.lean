-- Types/Inductive/ContainerBackend/Default.lean
-- [Crystalline] Container backend variants.

import Lean.Data.Json

/-- Container backend variants. -/
inductive ContainerBackend where
  | podman
  | docker
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson ContainerBackend where
  toJson
    | .podman => "podman"
    | .docker => "docker"
    | .none => "none"

instance : Lean.FromJson ContainerBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "podman" => pure .podman
    | "docker" => pure .docker
    | "none" => pure .none
    | _ => throw s!"unknown ContainerBackend: {s}"
