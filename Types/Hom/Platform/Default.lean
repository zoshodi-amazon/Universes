-- Types/Hom/Platform/Default.lean
-- [Liquid] Morphism into Platform phase — boot, disk, hardware, display.
-- Migrated from: Modules/Types/PhaseInputTypes/PlatformInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure PlatformHom where
  boot : BootConfig := {}
  display : DisplayConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
