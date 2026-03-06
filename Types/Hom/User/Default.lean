-- Types/Hom/User/Default.lean
-- [Liquid] Morphism into User phase (top-level) — git, browser, AI, cloud.
-- Migrated from: Modules/Types/PhaseInputTypes/UserInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure UserHom where
  git : GitConfig := {}
  browser : BrowserConfig := {}
  ai : AIConfig := {}
  cloud : CloudConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
