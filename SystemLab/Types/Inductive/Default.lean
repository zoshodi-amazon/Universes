-- Types/Inductive/Default.lean
-- [Crystalline] ADT / Sum types — finite enums with discrete symmetry.
-- Every string-that-is-an-enum in the system is extracted here as an inductive type.
-- No bare String for finite variants (Invariant #10).

import Lean.Data.Json

/-- Boot loader variants. -/
inductive BootLoader where
  | systemdBoot
  | grub
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson BootLoader where
  toJson
    | .systemdBoot => "systemd-boot"
    | .grub => "grub"
    | .none => "none"

instance : Lean.FromJson BootLoader where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "systemd-boot" => pure .systemdBoot
    | "grub" => pure .grub
    | "none" => pure .none
    | _ => throw s!"unknown BootLoader: {s}"

/-- Display backend variants. -/
inductive DisplayBackend where
  | wayland
  | x11
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DisplayBackend where
  toJson
    | .wayland => "wayland"
    | .x11 => "x11"
    | .none => "none"

instance : Lean.FromJson DisplayBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "wayland" => pure .wayland
    | "x11" => pure .x11
    | "none" => pure .none
    | _ => throw s!"unknown DisplayBackend: {s}"

/-- Display greeter variants. -/
inductive DisplayGreeter where
  | greetd
  | gdm
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DisplayGreeter where
  toJson
    | .greetd => "greetd"
    | .gdm => "gdm"
    | .none => "none"

instance : Lean.FromJson DisplayGreeter where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "greetd" => pure .greetd
    | "gdm" => pure .gdm
    | "none" => pure .none
    | _ => throw s!"unknown DisplayGreeter: {s}"

/-- Container backend variants. -/
inductive ContainerBackend where
  | podman
  | docker
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson ContainerBackend where
  toJson
    | .podman => "podman"
    | .docker => "docker"
    | .none => "none"

instance : Lean.FromJson ContainerBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "podman" => pure .podman
    | "docker" => pure .docker
    | "none" => pure .none
    | _ => throw s!"unknown ContainerBackend: {s}"

/-- Garbage collection interval variants. -/
inductive GcInterval where
  | daily
  | weekly
  | monthly
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GcInterval where
  toJson
    | .daily => "daily"
    | .weekly => "weekly"
    | .monthly => "monthly"

instance : Lean.FromJson GcInterval where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "daily" => pure .daily
    | "weekly" => pure .weekly
    | "monthly" => pure .monthly
    | _ => throw s!"unknown GcInterval: {s}"

/-- Sovereignty mode variants. -/
inductive SovereigntyMode where
  | base
  | full
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson SovereigntyMode where
  toJson
    | .base => "base"
    | .full => "full"

instance : Lean.FromJson SovereigntyMode where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "base" => pure .base
    | "full" => pure .full
    | _ => throw s!"unknown SovereigntyMode: {s}"

/-- Search engine variants. -/
inductive SearchEngine where
  | duckDuckGo
  | google
  | brave
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson SearchEngine where
  toJson
    | .duckDuckGo => "DuckDuckGo"
    | .google => "Google"
    | .brave => "Brave"

instance : Lean.FromJson SearchEngine where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "DuckDuckGo" => pure .duckDuckGo
    | "Google" => pure .google
    | "Brave" => pure .brave
    | _ => throw s!"unknown SearchEngine: {s}"

/-- AI provider variants. -/
inductive AIProvider where
  | amazonBedrock
  | openai
  | anthropic
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson AIProvider where
  toJson
    | .amazonBedrock => "amazon-bedrock"
    | .openai => "openai"
    | .anthropic => "anthropic"

instance : Lean.FromJson AIProvider where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "amazon-bedrock" => pure .amazonBedrock
    | "openai" => pure .openai
    | "anthropic" => pure .anthropic
    | _ => throw s!"unknown AIProvider: {s}"

/-- Machine architecture variants. -/
inductive MachineArch where
  | x86_64
  | aarch64
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson MachineArch where
  toJson
    | .x86_64 => "x86_64"
    | .aarch64 => "aarch64"

instance : Lean.FromJson MachineArch where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "x86_64" => pure .x86_64
    | "aarch64" => pure .aarch64
    | _ => throw s!"unknown MachineArch: {s}"

/-- Machine format variants. -/
inductive MachineFormat where
  | vm
  | iso
  | microvm
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson MachineFormat where
  toJson
    | .vm => "vm"
    | .iso => "iso"
    | .microvm => "microvm"

instance : Lean.FromJson MachineFormat where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "vm" => pure .vm
    | "iso" => pure .iso
    | "microvm" => pure .microvm
    | _ => throw s!"unknown MachineFormat: {s}"

/-- Default shell editor variants. -/
inductive ShellEditor where
  | nvim
  | vim
  | nano
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson ShellEditor where
  toJson
    | .nvim => "nvim"
    | .vim => "vim"
    | .nano => "nano"

instance : Lean.FromJson ShellEditor where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "nvim" => pure .nvim
    | "vim" => pure .vim
    | "nano" => pure .nano
    | _ => throw s!"unknown ShellEditor: {s}"

/-- Tmux prefix key variants. -/
inductive TmuxPrefix where
  | ctrlA
  | ctrlB
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson TmuxPrefix where
  toJson
    | .ctrlA => "C-a"
    | .ctrlB => "C-b"

instance : Lean.FromJson TmuxPrefix where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "C-a" => pure .ctrlA
    | "C-b" => pure .ctrlB
    | _ => throw s!"unknown TmuxPrefix: {s}"

/-- Kitty terminal theme variants. -/
inductive KittyTheme where
  | tokyoNightNight
  | catppuccinMocha
  | gruvboxDark
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson KittyTheme where
  toJson
    | .tokyoNightNight => "tokyo_night_night"
    | .catppuccinMocha => "catppuccin_mocha"
    | .gruvboxDark => "gruvbox_dark"

instance : Lean.FromJson KittyTheme where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "tokyo_night_night" => pure .tokyoNightNight
    | "catppuccin_mocha" => pure .catppuccinMocha
    | "gruvbox_dark" => pure .gruvboxDark
    | _ => throw s!"unknown KittyTheme: {s}"

/-- Editor colorscheme variants. -/
inductive Colorscheme where
  | tokyonight
  | catppuccin
  | gruvbox
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson Colorscheme where
  toJson
    | .tokyonight => "tokyonight"
    | .catppuccin => "catppuccin"
    | .gruvbox => "gruvbox"

instance : Lean.FromJson Colorscheme where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "tokyonight" => pure .tokyonight
    | "catppuccin" => pure .catppuccin
    | "gruvbox" => pure .gruvbox
    | _ => throw s!"unknown Colorscheme: {s}"

/-- Git default branch variants. -/
inductive GitBranch where
  | main
  | master
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GitBranch where
  toJson
    | .main => "main"
    | .master => "master"

instance : Lean.FromJson GitBranch where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "main" => pure .main
    | "master" => pure .master
    | _ => throw s!"unknown GitBranch: {s}"

/-- Cloud output format variants. -/
inductive CloudOutputFormat where
  | json
  | text
  | table
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson CloudOutputFormat where
  toJson
    | .json => "json"
    | .text => "text"
    | .table => "table"

instance : Lean.FromJson CloudOutputFormat where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "json" => pure .json
    | "text" => pure .text
    | "table" => pure .table
    | _ => throw s!"unknown CloudOutputFormat: {s}"

/-- Disk layout strategy variants. -/
inductive DiskLayout where
  | standard
  | custom
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DiskLayout where
  toJson
    | .standard => "standard"
    | .custom => "custom"
    | .none => "none"

instance : Lean.FromJson DiskLayout where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "standard" => pure .standard
    | "custom" => pure .custom
    | "none" => pure .none
    | _ => throw s!"unknown DiskLayout: {s}"

/-- Persistence strategy variants. -/
inductive PersistenceStrategy where
  | persistent
  | impermanent
  | ephemeral
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson PersistenceStrategy where
  toJson
    | .persistent => "persistent"
    | .impermanent => "impermanent"
    | .ephemeral => "ephemeral"

instance : Lean.FromJson PersistenceStrategy where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "persistent" => pure .persistent
    | "impermanent" => pure .impermanent
    | "ephemeral" => pure .ephemeral
    | _ => throw s!"unknown PersistenceStrategy: {s}"

/-- Hardware profile variants — drives automatic hardware configuration. -/
inductive HardwareProfile where
  | generic
  | laptop
  | desktop
  | server
  | vm
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson HardwareProfile where
  toJson
    | .generic => "generic"
    | .laptop => "laptop"
    | .desktop => "desktop"
    | .server => "server"
    | .vm => "vm"

instance : Lean.FromJson HardwareProfile where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "generic" => pure .generic
    | "laptop" => pure .laptop
    | "desktop" => pure .desktop
    | "server" => pure .server
    | "vm" => pure .vm
    | _ => throw s!"unknown HardwareProfile: {s}"

/-- GPU driver variants. -/
inductive GpuDriver where
  | none
  | intel
  | amd
  | nvidia
  | apple
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GpuDriver where
  toJson
    | .none => "none"
    | .intel => "intel"
    | .amd => "amd"
    | .nvidia => "nvidia"
    | .apple => "apple"

instance : Lean.FromJson GpuDriver where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "none" => pure .none
    | "intel" => pure .intel
    | "amd" => pure .amd
    | "nvidia" => pure .nvidia
    | "apple" => pure .apple
    | _ => throw s!"unknown GpuDriver: {s}"

/-- Audio backend variants. -/
inductive AudioBackend where
  | none
  | pipewire
  | pulseaudio
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson AudioBackend where
  toJson
    | .none => "none"
    | .pipewire => "pipewire"
    | .pulseaudio => "pulseaudio"

instance : Lean.FromJson AudioBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "none" => pure .none
    | "pipewire" => pure .pipewire
    | "pulseaudio" => pure .pulseaudio
    | _ => throw s!"unknown AudioBackend: {s}"
