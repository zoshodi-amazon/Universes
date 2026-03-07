-- CoTypes/CoInductive/Default.lean
-- Coalgebraic dual of Types/Inductive/ — Cofree / Codata types.
-- Re-export all CoInductive types + elimination validators.
-- One type per file (Invariant: 1-type-per-file).

import Lean.Data.Json
import Types.Inductive.Default
import CoTypes.CoInductive.CoInductiveWitness.Default
import CoTypes.CoInductive.CoInductiveExhaustiveness.Default

-- Elimination validators for each Inductive type.
-- These are the cofree observation interface: given a string, does it inhabit the type?

def validateBootLoader (s : String) : Bool :=
  s ∈ ["systemd-boot", "grub", "none"]

def validateDisplayBackend (s : String) : Bool :=
  s ∈ ["wayland", "x11", "none"]

def validateDisplayGreeter (s : String) : Bool :=
  s ∈ ["greetd", "gdm", "none"]

def validateContainerBackend (s : String) : Bool :=
  s ∈ ["podman", "docker", "none"]

def validateGcInterval (s : String) : Bool :=
  s ∈ ["daily", "weekly", "monthly"]

def validateSovereigntyMode (s : String) : Bool :=
  s ∈ ["base", "full"]

def validateSearchEngine (s : String) : Bool :=
  s ∈ ["DuckDuckGo", "Google", "Brave"]

def validateAIProvider (s : String) : Bool :=
  s ∈ ["amazon-bedrock", "openai", "anthropic"]

def validateMachineArch (s : String) : Bool :=
  s ∈ ["x86_64", "aarch64"]

def validateMachineFormat (s : String) : Bool :=
  s ∈ ["vm", "iso", "microvm"]

def validateShellEditor (s : String) : Bool :=
  s ∈ ["nvim", "vim", "nano"]

def validateTmuxPrefix (s : String) : Bool :=
  s ∈ ["C-a", "C-b"]

def validateKittyTheme (s : String) : Bool :=
  s ∈ ["tokyo_night_night", "catppuccin_mocha", "gruvbox_dark"]

def validateColorscheme (s : String) : Bool :=
  s ∈ ["tokyonight", "catppuccin", "gruvbox"]

def validateGitBranch (s : String) : Bool :=
  s ∈ ["main", "master"]

def validateCloudOutputFormat (s : String) : Bool :=
  s ∈ ["json", "text", "table"]

def validateDiskLayout (s : String) : Bool :=
  s ∈ ["standard", "custom", "none"]

def validatePersistenceStrategy (s : String) : Bool :=
  s ∈ ["persistent", "impermanent", "ephemeral"]

def validateHardwareProfile (s : String) : Bool :=
  s ∈ ["generic", "laptop", "desktop", "server", "vm"]

def validateGpuDriver (s : String) : Bool :=
  s ∈ ["none", "intel", "amd", "nvidia", "apple"]

def validateAudioBackend (s : String) : Bool :=
  s ∈ ["none", "pipewire", "pulseaudio"]
