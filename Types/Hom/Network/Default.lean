-- Types/Hom/Network/Default.lean
-- [Liquid] Morphism into Network phase — firewall, SSH, wireless.
-- Migrated from: Modules/Types/PhaseInputTypes/NetworkInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure NetworkHom where
  network : NetworkConfig := {}
  ssh : SshConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
