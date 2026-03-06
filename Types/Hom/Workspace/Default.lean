-- Types/Hom/Workspace/Default.lean
-- [Liquid] Morphism into Workspace phase — devShells, labs.
-- Migrated from: Modules/Types/PhaseInputTypes/WorkspaceInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure WorkspaceHom where
  sovereignty : SovereigntyConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
