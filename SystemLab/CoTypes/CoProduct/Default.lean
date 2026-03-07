-- CoTypes/CoProduct/Default.lean
-- Coalgebraic dual of Types/Product/ — Coproduct / observation outputs.
-- Where Product types record what a phase produced (outputs + meta),
-- CoProduct types record what an observer saw (co-outputs + co-meta).
-- Populated by path (a) schema observation or path (b) runtime observation.
-- Agreement between paths = bidirectional path closure = correctness.
-- Duality: Product ↔ Coproduct

import Lean.Data.Json

-- ============================================================================
-- Observation Outputs (what was seen per phase)
-- ============================================================================

/-- Observation output for Identity phase. -/
structure CoIdentityOutput where
  nixEnabled : Bool := false
  gcActive : Bool := false
  substituters : List String := []
  sopsKeyPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for Platform phase. -/
structure CoPlatformOutput where
  kernelVersion : Option String := none
  bootloaderType : Option String := none
  displayBackend : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for Network phase. -/
structure CoNetworkOutput where
  firewallActive : Bool := false
  openPorts : List Nat := []
  sshRunning : Bool := false
  sshMatchBlocks : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for Services phase. -/
structure CoServicesOutput where
  containerBackendRunning : Bool := false
  containerCount : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for User phase (top-level). -/
structure CoUserOutput where
  gitConfigured : Bool := false
  browserInstalled : Bool := false
  aiConfigured : Bool := false
  cloudConfigured : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for Workspace phase. -/
structure CoWorkspaceOutput where
  devShellsAvailable : List String := []
  sovereigntyMode : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation output for Deploy phase. -/
structure CoDeployOutput where
  homeConfigurations : List String := []
  nixosConfigurations : List String := []
  machineImages : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson

-- ============================================================================
-- Observation Meta (when and how observed)
-- ============================================================================

/-- Observation metadata — common across all phases. -/
structure CoObservationMeta where
  observedAt : String := ""
  observerHost : String := ""
  durationMs : Nat := 0
  pathA : Bool := false  -- schema observation was performed
  pathB : Bool := false  -- runtime observation was performed
  pathsAgree : Bool := false  -- bidirectional path closure holds
  deriving Repr, Lean.ToJson, Lean.FromJson

-- ============================================================================
-- Per-phase CoProduct (Output + Meta)
-- ============================================================================

structure CoIdentityProduct where
  observed : CoIdentityOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoPlatformProduct where
  observed : CoPlatformOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoNetworkProduct where
  observed : CoNetworkOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoServicesProduct where
  observed : CoServicesOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoUserProduct where
  observed : CoUserOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoWorkspaceProduct where
  observed : CoWorkspaceOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoDeployProduct where
  observed : CoDeployOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
