-- CoTypes/CoDependent/Default.lean
-- Coalgebraic dual of Types/Dependent/ — Cofibrations.
-- Where Dependent types are fibrations (indexed families over Inductive variants),
-- CoDependent types define the lifting property: given an observation,
-- can it be lifted back to its fiber? Schema conformance validators.
-- Duality: Fibration ↔ Cofibration

import Lean.Data.Json
import Types.Inductive.Default

/-- Schema conformance result — does an observation inhabit its expected fiber? -/
structure CoSchemaResult where
  structureName : String
  conformant : Bool := false
  missingFields : List String := []
  extraFields : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of NixSettings — lifting back to the GcInterval fiber. -/
structure CoNixSettings where
  enableObserved : Bool := false
  gcAutomaticObserved : Bool := false
  gcIntervalValid : Bool := false
  optimiseObserved : Bool := false
  maxJobsObserved : Option String := none
  coresObserved : Option Nat := none
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of SopsConfig — is the age key file reachable? -/
structure CoSopsConfig where
  enableObserved : Bool := false
  ageKeyFileExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of BootConfig — lifting back to the BootLoader fiber. -/
structure CoBootConfig where
  enableObserved : Bool := false
  loaderValid : Bool := false
  efiObserved : Bool := false
  kernelPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of DisplayConfig — lifting back to DisplayBackend + DisplayGreeter fibers. -/
structure CoDisplayConfig where
  enableObserved : Bool := false
  backendValid : Bool := false
  greeterValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of NetworkConfig. -/
structure CoNetworkConfig where
  enableObserved : Bool := false
  dhcpObserved : Bool := false
  firewallActive : Bool := false
  firewallPortsOpen : List Nat := []
  sshListening : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of SshConfig. -/
structure CoSshConfig where
  enableObserved : Bool := false
  compressionObserved : Bool := false
  serverAliveIntervalObserved : Option Nat := none
  forwardAgentObserved : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of ContainerConfig — lifting back to ContainerBackend fiber. -/
structure CoContainerConfig where
  enableObserved : Bool := false
  backendValid : Bool := false
  backendRunning : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of SovereigntyConfig — lifting back to SovereigntyMode fiber. -/
structure CoSovereigntyConfig where
  modeValid : Bool := false
  bootstrapSeedPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of GitConfig. -/
structure CoGitConfig where
  enableObserved : Bool := false
  userNameSet : Bool := false
  userEmailSet : Bool := false
  defaultBranchValid : Bool := false
  deltaInstalled : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of BrowserConfig — lifting back to SearchEngine fiber. -/
structure CoBrowserConfig where
  enableObserved : Bool := false
  searchDefaultValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of AIConfig — lifting back to AIProvider fiber. -/
structure CoAIConfig where
  enableObserved : Bool := false
  providerValid : Bool := false
  regionSet : Bool := false
  profileSet : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of CloudConfig — lifting back to CloudOutputFormat fiber. -/
structure CoCloudConfig where
  enableObserved : Bool := false
  defaultRegionSet : Bool := false
  defaultOutputValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of HomeTarget. -/
structure CoHomeTarget where
  enableObserved : Bool := false
  usernameMatches : Bool := false
  homeDirectoryExists : Bool := false
  stateVersionValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of MachineConfig — lifting back to MachineArch + MachineFormat fibers. -/
structure CoMachineConfig where
  name : String
  hostnameResolvable : Bool := false
  archValid : Bool := false
  formatValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of DiskConfig — lifting back to DiskLayout fiber. -/
structure CoDiskConfig where
  layoutValid : Bool := false
  deviceExists : Bool := false
  filesystemValid : Bool := false
  encryptionActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of PersistenceConfig — lifting back to PersistenceStrategy fiber. -/
structure CoPersistenceConfig where
  strategyValid : Bool := false
  deviceMounted : Bool := false
  pathsExist : List Bool := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of MachineUser — is the user account present? -/
structure CoMachineUser where
  name : String
  accountExists : Bool := false
  groupsPresent : List Bool := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation of HardwareConfig — lifting back to HardwareProfile + GpuDriver + AudioBackend fibers. -/
structure CoHardwareConfig where
  enableObserved : Bool := false
  profileValid : Bool := false
  gpuDriverLoaded : Bool := false
  firmwarePresent : Bool := false
  audioRunning : Bool := false
  bluetoothActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
