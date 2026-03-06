-- CoTypes/Comonad/Default.lean
-- Coalgebraic dual of Types/Monad/ — Trace comonad.
-- Where Monad types record effects that happened (errors, metrics, alarms),
-- Comonad types record the observation cursor state (where in the stream the observer is).
-- Duality: Effects ↔ Co-effects (traces)
--
-- Comonad laws (categorical dual of Monad):
--   extract : W A → A           (dual of return  : A → M A)
--   extend  : (W A → B) → W B   (dual of bind    : M A → (A → M B) → M B)
--
-- TODO: Populate when observer patterns are needed at the Nix level.
-- See RL/CoTypes/CoMonad/Trace/default.py (TraceComonad) for the Python reference.

import Lean.Data.Json
