-- Types/Hom/Services/Default.lean
-- [Liquid] Morphism into Services phase — containers, servers.
-- Migrated from: Modules/Types/PhaseInputTypes/ServicesInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure ServicesHom where
  containers : ContainerConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
