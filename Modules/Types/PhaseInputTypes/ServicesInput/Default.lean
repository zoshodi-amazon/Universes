import Lean.Data.Json

structure ContainerConfig where
  enable : Bool := false
  backend : String := "podman"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ServicesInput where
  containers : ContainerConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
