-- CoTypes/CoIO/Default.lean
-- Coalgebraic dual of Types/IO/ — Observer executors.
-- Where IO executors run phase computations (eval/apply),
-- CoIO executors observe phase computations without participating in the phase chain.
-- Duality: Executors ↔ Observers
--
-- TODO: Populate when observer patterns are needed at the Nix level.
-- See RL/CoTypes/IO/IOTailPhase/ and IOVisualizePhase/ for the Python reference.

import Lean.Data.Json
