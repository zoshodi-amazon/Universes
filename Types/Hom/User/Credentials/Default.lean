-- Types/Hom/User/Credentials/Default.lean
-- [Liquid] Morphism into User Credentials sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/CredentialsInput/Default.lean

import Lean.Data.Json
import Inductive.Default

structure UserCredentialsHom where
  gitEnable : Bool := true
  gitUserName : String := ""
  gitUserEmail : String := ""
  gitDefaultBranch : GitBranch := .main
  gitDelta : Bool := true
  gitLfs : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
