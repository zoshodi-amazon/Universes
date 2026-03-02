import Lean.Data.Json

structure GitConfig where
  enable : Bool := true
  userName : String := ""
  userEmail : String := ""
  defaultBranch : String := "main"
  delta : Bool := true
  lfs : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

structure BrowserConfig where
  enable : Bool := false
  searchDefault : String := "DuckDuckGo"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure AIConfig where
  enable : Bool := true
  provider : String := "amazon-bedrock"
  region : String := "us-east-1"
  profile : String := "conduit"
  endpoint : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CloudConfig where
  enable : Bool := true
  defaultRegion : String := "us-east-1"
  defaultOutput : String := "json"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure UserInput where
  git : GitConfig := {}
  browser : BrowserConfig := {}
  ai : AIConfig := {}
  cloud : CloudConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
