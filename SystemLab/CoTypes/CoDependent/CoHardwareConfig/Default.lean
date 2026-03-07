-- CoTypes/CoDependent/CoHardwareConfig/Default.lean
-- Cofibration — observation of HardwareConfig.

import Lean.Data.Json

/-- Observation of HardwareConfig — lifting back to HardwareProfile + GpuDriver + AudioBackend fibers. -/
structure CoHardwareConfig where
  enableObserved : Bool := false
  profileValid : Bool := false
  gpuDriverLoaded : Bool := false
  firmwarePresent : Bool := false
  audioRunning : Bool := false
  bluetoothActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
