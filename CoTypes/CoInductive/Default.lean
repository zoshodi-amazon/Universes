-- CoTypes/CoInductive/Default.lean
-- Coalgebraic dual of Types/Inductive/ — Cofree / Codata types.
-- Where Inductive types are finite sum types (constructors, pattern matching),
-- CoInductive types are coinductive streams (destructors, observation).
-- Duality: Free ↔ Cofree
--
-- TODO: Populate when observer patterns are needed at the Nix level.
-- See RL/CoTypes/CoInductive/ for the Python reference implementation.

import Lean.Data.Json
