-- Types/Dependent/BrowserConfig/Default.lean
-- [Liquid Crystal] Browser configuration — parameterized by SearchEngine.

import Lean.Data.Json
import Types.Inductive.SearchEngine.Default

/-- Browser configuration — parameterized by SearchEngine. -/
structure BrowserConfig where
  enable : Bool := false
  searchDefault : SearchEngine := .duckDuckGo
  deriving Repr, Lean.ToJson, Lean.FromJson
