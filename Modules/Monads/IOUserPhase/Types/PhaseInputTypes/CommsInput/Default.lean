import Lean.Data.Json
structure CommsInput where
  browserEnable : Bool := false
  aiEnable : Bool := true
  aiProvider : String := "amazon-bedrock"
  aiProfile : String := "conduit"
  cloudEnable : Bool := true
  mailEnable : Bool := true
  deriving Repr, Lean.ToJson, Lean.FromJson
