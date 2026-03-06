-- Types/Hom/Identity/Default.lean
-- [Liquid] Morphism into Identity phase — Nix daemon + secrets configuration.
-- Migrated from: Modules/Types/PhaseInputTypes/IdentityInput/Default.lean

import Lean.Data.Json
import Dependent.Default

structure IdentityHom where
  nixSettings : NixSettings := {}
  sops : SopsConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
