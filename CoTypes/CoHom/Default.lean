-- CoTypes/CoHom/Default.lean
-- Coalgebraic dual of Types/Hom/ — Destructors / observation morphisms.
-- Where Hom types are morphisms flowing INTO a phase (constructors),
-- CoHom types are observation specifications flowing OUT (destructors).
-- Field-parallel to Hom/ with observation types (Bool, Option).
-- Duality: Constructors ↔ Destructors

import Lean.Data.Json
import CoTypes.CoDependent.Default

/-- Observation specification for Identity phase — what to check.
    Field-parallel to IdentityHom (nixSettings, sops). -/
structure CoIdentityHom where
  coNixSettings : CoNixSettings := {}
  coSops : CoSopsConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for Platform phase — what to check.
    Field-parallel to PlatformHom (boot, display). -/
structure CoPlatformHom where
  coBoot : CoBootConfig := {}
  coDisplay : CoDisplayConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for Network phase — what to check.
    Field-parallel to NetworkHom (network, ssh). -/
structure CoNetworkHom where
  coNetwork : CoNetworkConfig := {}
  coSsh : CoSshConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for Services phase — what to check.
    Field-parallel to ServicesHom (containers). -/
structure CoServicesHom where
  coContainers : CoContainerConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for User phase (top-level) — what to check.
    Field-parallel to UserHom (git, browser, ai, cloud). -/
structure CoUserHom where
  coGit : CoGitConfig := {}
  coBrowser : CoBrowserConfig := {}
  coAi : CoAIConfig := {}
  coCloud : CoCloudConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for Workspace phase — what to check.
    Field-parallel to WorkspaceHom (sovereignty). -/
structure CoWorkspaceHom where
  coSovereignty : CoSovereigntyConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation specification for Deploy phase — what to check.
    Field-parallel to DeployHom (home, machines). -/
structure CoDeployHom where
  coHomeDarwin : CoHomeTarget := {}
  coHomeCloudDev : CoHomeTarget := {}
  coMachines : List CoMachineConfig := []
  deriving Repr, Lean.ToJson, Lean.FromJson
