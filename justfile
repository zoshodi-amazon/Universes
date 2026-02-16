# ===============================================================================
# UNIVERSES - Dendritic Nix Configuration System
# ===============================================================================
#
# NAME
#     justfile - Capability-centric module and machine management
#
# SYNOPSIS
#     just <recipe> [arguments...]
#     just --list
#
# DESCRIPTION
#     Single source of truth for all Universes operations.
#     Organized by capability, not implementation.
#
#     INTROSPECT  - Discover modules, features, and options
#     CREATE      - Scaffold new modules and features
#     BUILD       - Compile and validate
#     DEPLOY      - Flash and connect to machines
#     SYNC        - Remote build operations
#     FLAKE       - Flake inspection and management
#     STORE       - Nix store operations
#
# PHILOSOPHY
#     Index on CAPABILITY, not IMPLEMENTATION.
#     Options define types (what), Bindings define terms (how).
#     See Prelude/AGENTS.md for full ontology.
#
# ===============================================================================

scripts := "Prelude/Modules/Labs/Scripts/Universe"

default:
    @just --list

# -------------------------------------------------------------------------------
# INTROSPECT
# -------------------------------------------------------------------------------

# List all modules by category (Labs, User, Host, Fleet)
modules:
    @gum style --border normal --padding "0 1" "Modules"
    @nu {{scripts}}/Discover/Bindings/Scripts/default.nu

# List Universe features in a module
# ARGS: module - path to module (e.g., Prelude/Modules/User/Terminal/Shell)
features module:
    @gum style --border normal --padding "0 1" "Features in $(gum style --foreground 212 '{{module}}')"
    @nu {{scripts}}/Introspect/Bindings/Scripts/default.nu '{"mode": "features", "module": "{{module}}"}'

# Show Options type space for all features in a module
# ARGS: module - path to module (e.g., Prelude/Modules/User/Terminal/Shell)
options module:
    @gum style --border normal --padding "0 1" "Options in $(gum style --foreground 212 '{{module}}')"
    @nu {{scripts}}/Introspect/Bindings/Scripts/default.nu '{"mode": "options", "module": "{{module}}"}'

# Show machine options schema (capability space for machine definitions)
schema:
    @gum style --border normal --padding "0 1" "Machine Schema"
    @echo "machines.<name> = {"
    @echo "  identity.hostname    : str           # What is this machine called?"
    @echo "  target.arch          : enum          # x86_64 | aarch64"
    @echo "  format.type          : enum          # iso | vm | sd-image | raw-efi | oci"
    @echo "  persistence.strategy : enum          # full | impermanent | ephemeral"
    @echo "  persistence.device   : str?          # e.g., /dev/disk/by-label/NIXOS_PERSIST"
    @echo "  persistence.paths    : [str]         # Directories to persist"
    @echo "  disk.layout          : enum          # standard | custom | none"
    @echo "  disk.device          : str           # e.g., /dev/sda"
    @echo "  disk.persistLabel    : str           # e.g., NIXOS_PERSIST"
    @echo "  users                : [user]        # Users on this machine"
    @echo "};"

# List all defined machines (queries flake.nixosConfigurations)
list:
    @gum style --border normal --padding "0 1" "Machines"
    @nix eval .#nixosConfigurations --apply 'x: builtins.attrNames x' 2>/dev/null || echo "(eval error - run on Linux)"

# -------------------------------------------------------------------------------
# CREATE
# -------------------------------------------------------------------------------

# Scaffold a new module from frozen template
# ARGS: path - module path (e.g., Prelude/Modules/User/Foo)
new-module path:
    @gum style --border normal --padding "0 1" "Creating module $(gum style --foreground 212 '{{path}}')"
    @nu {{scripts}}/Scaffold/Bindings/Scripts/default.nu '{"mode": "module", "path": "{{path}}"}'
    @gum style --foreground 82 "Module created"

# Add a feature to a module (creates Universe/<name> with Options/Bindings)
# ARGS: module - path to module, name - feature name
new-feature module name:
    @gum style --border normal --padding "0 1" "Creating feature $(gum style --foreground 212 '{{name}}') in $(gum style --foreground 212 '{{module}}')"
    @nu {{scripts}}/Scaffold/Bindings/Scripts/default.nu '{"mode": "feature", "path": "{{module}}", "name": "{{name}}"}'
    @gum style --foreground 82 "Feature created"

# -------------------------------------------------------------------------------
# BUILD
# -------------------------------------------------------------------------------

# Build a machine image based on its format.type option
# ARGS: machine - name of machine (e.g., sovereignty)
build machine:
    @gum style --border normal --padding "0 1" "Building $(gum style --foreground 212 '{{machine}}')"
    @nom build .#{{machine}}-iso --print-out-paths
    @gum style --foreground 82 "Build complete"

# Run machine in QEMU VM for testing before flashing
# ARGS: machine - name of machine
vm machine:
    @gum style --foreground 212 "Starting VM: {{machine}}"
    @nix run .#{{machine}}-vm

# Validate all modules (runs nix flake check)
check:
    @gum style --border normal --padding "0 1" "Checking flake"
    @nix flake check --show-trace 2>&1 | nom
    @gum style --foreground 82 "Check passed"

# -------------------------------------------------------------------------------
# DEPLOY
# -------------------------------------------------------------------------------

# Flash ISO to USB drive
# ARGS: machine - name of machine, disk - target disk (e.g., /dev/disk4)
flash machine disk:
    @gum style --border normal --foreground 196 --padding "0 1" "WARNING: This will erase {{disk}}"
    @gum confirm "Flash {{machine}} to {{disk}}?" && nu {{scripts}}/Deploy/Bindings/Scripts/default.nu '{"mode": "flash", "machine": "{{machine}}", "disk": "{{disk}}"}'

# Unmount all volumes on a disk (required before flashing)
# ARGS: disk - target disk (e.g., /dev/disk4)
unmount disk:
    @gum style --foreground 212 "Unmounting {{disk}}"
    @diskutil unmountDisk {{disk}} 2>/dev/null || echo "Already unmounted"

# Format SD card for persistence (ext4 with label NIXOS_PERSIST)
# ARGS: disk - target disk (e.g., /dev/sdb)
format-persist disk:
    @gum style --border normal --foreground 196 --padding "0 1" "WARNING: This will erase {{disk}}"
    @gum confirm "Format {{disk}} for persistence?" && nu {{scripts}}/Deploy/Bindings/Scripts/default.nu '{"mode": "format-persist", "disk": "{{disk}}"}'

# SSH into a deployed machine
# ARGS: machine - hostname, user - SSH user (optional)
ssh machine user="":
    @gum style --foreground 212 "Connecting to {{machine}}"
    @if [ -z "{{user}}" ]; then ssh {{machine}}; else ssh {{user}}@{{machine}}; fi

# Install to remote machine via nixos-anywhere + disko
# ARGS: host - SSH host, machine - machine name
remote-install host machine:
    @gum style --border normal --padding "0 1" "Installing $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}') via nixos-anywhere"
    @just sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run github:nix-community/nixos-anywhere -- --flake .#{{machine}} root@localhost"

# -------------------------------------------------------------------------------
# SYNC
# -------------------------------------------------------------------------------

# Sync repo to remote host (for building on Linux from macOS)
# ARGS: host - SSH host (e.g., cloud-dev)
sync-to host:
    @gum style --border normal --padding "0 1" "Syncing to $(gum style --foreground 212 '{{host}}')"
    @gum spin --spinner dot --title "Syncing..." -- rsync -avz --delete ~/repos/Universes/ {{host}}:~/repos/Universes/
    @gum style --foreground 82 "Sync complete"

# Build on remote host and copy ISO back to ~/Downloads/<machine>.iso
# ARGS: host - SSH host, machine - name of machine
remote-build host machine:
    @gum style --border normal --padding "0 1" "Remote build $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @nu {{scripts}}/Deploy/Bindings/Scripts/default.nu '{"mode": "remote-build", "host": "{{host}}", "machine": "{{machine}}"}'

# Build OCI image on remote host and copy back
# ARGS: host - SSH host, machine - name of machine
remote-build-oci host machine:
    @gum style --border normal --padding "0 1" "Remote build OCI $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @nu {{scripts}}/Deploy/Bindings/Scripts/default.nu '{"mode": "remote-build-oci", "host": "{{host}}", "machine": "{{machine}}"}'

# Build VM on remote host and run locally via QEMU
# ARGS: host - SSH host, machine - name of machine
remote-build-vm host machine:
    @gum style --border normal --padding "0 1" "Remote build VM $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @nu {{scripts}}/Deploy/Bindings/Scripts/default.nu '{"mode": "remote-build-vm", "host": "{{host}}", "machine": "{{machine}}"}'

# Load OCI image into local podman
# ARGS: machine - name of machine
load-oci machine:
    @gum style --border normal --padding "0 1" "Loading OCI $(gum style --foreground 212 '{{machine}}')"
    @podman machine start 2>/dev/null || true
    @podman load < ~/Downloads/{{machine}}.tar.gz
    @gum style --foreground 82 "Loaded {{machine}}:latest"

# Run OCI image in podman (privileged for NixOS system containers)
# ARGS: machine - name of machine
run-oci machine:
    @gum style --foreground 212 "Running {{machine}}"
    @podman machine start 2>/dev/null || true
    @podman run -it --privileged {{machine}}:latest

# Run VM locally via QEMU
# ARGS: machine - name of machine
run-vm machine:
    @gum style --foreground 212 "Running VM {{machine}}"
    @~/VMs/{{machine}}/bin/run-*-vm

# Run VM on remote host via SSH (with X11 forwarding)
# ARGS: host - SSH host, machine - name of machine
run-vm-remote host machine:
    @gum style --foreground 212 "Running VM {{machine}} on {{host}}"
    @ssh -Y {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run .#{{machine}}-vm"

# Build and run MicroVM on remote host
# ARGS: host - SSH host, machine - name of machine (must have format.type = "microvm")
remote-microvm host machine:
    @gum style --border normal --padding "0 1" "MicroVM $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run .#{{machine}}-microvm"

# SSH into running MicroVM on remote host (via port forward 2222)
# ARGS: host - SSH host, user - guest user (default: root)
ssh-microvm host user="root":
    @gum style --foreground 212 "SSH to MicroVM via {{host}}:2222"
    @ssh -J {{host}} -p 2222 {{user}}@localhost

# Initialize podman machine (Darwin only, run once)
podman-init:
    @gum style --border normal --padding "0 1" "Initializing podman machine"
    @podman machine init
    @podman machine start
    @gum style --foreground 82 "Podman machine ready"

# -------------------------------------------------------------------------------
# HOME
# -------------------------------------------------------------------------------

# Switch to home configuration
# ARGS: host - home configuration name (default: darwin)
switch host="darwin":
    @gum style --border normal --padding "0 1" "Switching to $(gum style --foreground 212 '{{host}}')"
    @nh home switch . -c {{host}}

# Sync to remote host and switch home configuration there
# ARGS: host - SSH host (e.g., cloud-dev), config - home configuration name (default: cloud-dev)
remote-switch host config="cloud-dev":
    @just sync-to {{host}}
    @gum style --border normal --padding "0 1" "Switching $(gum style --foreground 212 '{{config}}') on $(gum style --foreground 212 '{{host}}')"
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && home-manager switch --flake .#{{config}}"
    @gum style --foreground 82 "Remote switch complete"

# -------------------------------------------------------------------------------
# PRESETS
# -------------------------------------------------------------------------------

preset_scripts := "Prelude/Modules/Labs/Scripts/Universe/Preset"

# List available tmux presets
presets:
    @nu {{preset_scripts}}/Bindings/Scripts/default.nu list

# Launch tmux preset session
# ARGS: name - preset name, domain - lab domain (Audio, Video, etc.)
preset name domain="Audio":
    @nu {{preset_scripts}}/Bindings/Scripts/default.nu '{"preset": "{{name}}", "workdir": "Prelude/Modules/Labs/{{domain}}"}'

# -------------------------------------------------------------------------------
# LABS
# -------------------------------------------------------------------------------

# Launch Lab in domain-specific preset
# ARGS: domain - lab domain (Audio, RL, Game, etc.)
lab domain="Audio":
    #!/usr/bin/env nu
    let preset: string = match "{{domain}}" {
      "RL" => "rl"
      _ => "explore"
    }
    nu Prelude/Modules/Labs/Scripts/Universe/Preset/Bindings/Scripts/default.nu $'{"preset": "($preset)", "workdir": "Prelude/Modules/Labs/{{domain}}"}'

# -------------------------------------------------------------------------------
# FLAKE
# -------------------------------------------------------------------------------

# Show all flake outputs
show:
    nix flake show

# Update all inputs
update:
    nix flake update

# Update specific input
update-input input:
    nix flake update {{input}}

# Run REPL with flake
repl:
    nix repl .#

# Eval any config path
eval path:
    nix eval '.#{{path}}'

# Eval as JSON
eval-json path:
    nix eval --json '.#{{path}}' | jq

# List attribute names at path
keys path:
    @nix eval --json '.#{{path}}' --apply 'builtins.attrNames' | jq -r '.[]'

# List homeManager modules
modules-home:
    @nix eval --json '.#modules.homeManager' --apply 'builtins.attrNames' | jq -r '.[]'

# List nixos modules
modules-nixos:
    @nix eval --json '.#modules.nixos' --apply 'builtins.attrNames' | jq -r '.[]'

# Show nixvim keymaps
keymaps host="darwin":
    @nix eval '.#homeConfigurations.{{host}}.config.programs.nixvim.keymaps' 2>&1 \
        | grep -oE 'key = "[^"]+";.*desc = "[^"]+"' \
        | sed 's/key = "//; s/";.*desc = "/ → /; s/"$//'

# Show enabled plugins
plugins host="darwin":
    @nix eval --json '.#homeConfigurations.{{host}}.config.programs.nixvim.plugins' \
        --apply 'p: builtins.filter (n: n != "__unfix__") (builtins.attrNames p)' | jq -r '.[]'

# -------------------------------------------------------------------------------
# STORE
# -------------------------------------------------------------------------------

# Garbage collect (default: older than 7 days)
gc days="7":
    nix-collect-garbage --delete-older-than {{days}}d

# Show store path size
size path="./result":
    nix path-info -Sh {{path}}

# Optimize store
optimize:
    nix store optimise

# Search nixpkgs
search query:
    nix search nixpkgs {{query}}

# Show package meta
info pkg:
    nix eval --json '{{pkg}}.meta' | jq

# Run package without installing
run pkg *args:
    nix run {{pkg}} -- {{args}}

# -------------------------------------------------------------------------------
# DISCOVER
# -------------------------------------------------------------------------------

# List curated nixpkgs tools for a capability domain
# ARGS: domain - capability domain (electrical, acoustic, mechanical, chemical, biological, visual, rf, device, cad)
discover domain:
    #!/usr/bin/env nu
    let tools: record = {
      electrical: [
        { pkg: "kicad-small", cap: "schematic + PCB layout + gerber export" }
        { pkg: "ngspice", cap: "SPICE circuit simulation" }
        { pkg: "qucs-s", cap: "circuit simulation GUI with SPICE backends" }
        { pkg: "xyce", cap: "high-performance analog circuit sim (linux)" }
        { pkg: "librepcb", cap: "EDA suite (linux)" }
      ]
      acoustic: [
        { pkg: "sox", cap: "audio transforms, spectrum, format conversion" }
        { pkg: "ffmpeg", cap: "audio/video encode, decode, filter, stream" }
        { pkg: "audacity", cap: "waveform editor + spectrum analysis" }
      ]
      mechanical: [
        { pkg: "openscad", cap: "parametric 3D CAD (code-driven)" }
        { pkg: "freecad", cap: "general purpose 3D CAD/FEA (linux)" }
        { pkg: "calculix-ccx", cap: "FEA structural analysis" }
        { pkg: "meshlab", cap: "3D mesh processing + conversion" }
        { pkg: "blender", cap: "3D modeling, rendering, simulation" }
      ]
      chemical: [
        { pkg: "openbabel", cap: "molecule format conversion (SMILES, SDF, PDB)" }
        { pkg: "avogadro2", cap: "molecular editor + visualizer" }
      ]
      biological: [
        { pkg: "blast", cap: "sequence alignment search" }
        { pkg: "clustalw", cap: "multiple sequence alignment" }
      ]
      visual: [
        { pkg: "imagemagick", cap: "image conversion, transform, compose" }
        { pkg: "ffmpeg", cap: "video encode, decode, filter, stream" }
        { pkg: "blender", cap: "3D rendering + compositing" }
      ]
      rf: [
        { pkg: "gnuradio", cap: "SDR signal processing framework" }
        { pkg: "rtl-sdr", cap: "RTL2832U SDR receiver tools" }
        { pkg: "hackrf", cap: "HackRF One TX/RX tools" }
        { pkg: "gqrx", cap: "SDR receiver GUI + spectrum" }
        { pkg: "sigrok-cli", cap: "logic analyzer + protocol decode" }
        { pkg: "inspectrum", cap: "SDR signal analysis (linux)" }
        { pkg: "dump1090", cap: "ADS-B aircraft tracking" }
        { pkg: "rtl_433", cap: "ISM band device decoder" }
        { pkg: "multimon-ng", cap: "digital radio decoder (POCSAG, FLEX, etc)" }
      ]
      device: [
        { pkg: "tio", cap: "serial console (modern, auto-detect)" }
        { pkg: "picocom", cap: "minimal serial terminal" }
        { pkg: "minicom", cap: "modem control + serial terminal" }
        { pkg: "dfu-util", cap: "USB DFU firmware flash" }
        { pkg: "esptool", cap: "ESP8266/ESP32 flash + monitor" }
        { pkg: "avrdude", cap: "AVR microcontroller programmer" }
        { pkg: "stlink", cap: "STM32 debug + flash" }
      ]
      cad: [
        { pkg: "openscad", cap: "parametric 3D (code-driven, STL export)" }
        { pkg: "freecad", cap: "general 3D CAD + FEA + STEP (linux)" }
        { pkg: "blender", cap: "3D modeling + rendering + STL/OBJ" }
        { pkg: "kicad-small", cap: "PCB/schematic EDA + gerber" }
        { pkg: "librepcb", cap: "PCB EDA (linux)" }
      ]
    }
    let domain_str: string = "{{domain}}"
    if ($domain_str in $tools) {
      let entries: table = ($tools | get $domain_str)
      print (["Domain:" $domain_str] | str join " ")
      print ""
      $entries | each {|e|
        print ([" " $e.pkg "-" $e.cap] | str join " ")
      }
      print ""
      print "Try: just try <pkg> --help"
    } else {
      let domains: string = ($tools | columns | str join ", ")
      print (["Available domains:" $domains] | str join " ")
    }

# Try a nixpkgs tool with zero commitment
# ARGS: pkg - package name, args - arguments to pass
try pkg *args:
    nix run nixpkgs#{{pkg}} -- {{args}}

# Check platform support for a nixpkgs package
# ARGS: pkg - package name
platforms pkg:
    #!/usr/bin/env nu
    let json: string = (nix eval (["nixpkgs#" "{{pkg}}" ".meta.platforms"] | str join "") --json | str trim)
    let plats: list<string> = ($json | from json)
    let darwin: bool = ("aarch64-darwin" in $plats)
    let linux: bool = ("x86_64-linux" in $plats)
    print (["{{pkg}}:" "darwin=" ($darwin | into string) "linux=" ($linux | into string)] | str join " ")

# -------------------------------------------------------------------------------
# SOVEREIGNTY — Pipelines only (execution contexts → RunRecord)
# -------------------------------------------------------------------------------

# Full sovereignty audit: <EnvBase, RunBase, PhaseOverlay[Survival,Infrastructure,Recon]>
io-python-sovereignty *args="":
    python Monads/Pipelines/IOMPythonSovereignty/default.py {{args}}

# Fabrication pipeline: scan → reconstruct → mesh → slice → gcode
io-python-fabpipeline *args="":
    python Monads/Pipelines/IOMPythonFabPipeline/default.py {{args}}

# Reconnaissance pipeline: survey → scan → capture → report
io-python-reconpipeline *args="":
    python Monads/Pipelines/IOMPythonReconPipeline/default.py {{args}}

# Robotics sim pipeline: URDF → PyBullet → RL → policy
io-python-robotsim *args="":
    python Monads/Pipelines/IOMPythonRobotSim/default.py {{args}}

# -------------------------------------------------------------------------------
# INVARIANTS
# -------------------------------------------------------------------------------

# Run all invariant checks for current system
invariants:
    #!/usr/bin/env bash
    sys=$(nix eval --raw --impure --expr 'builtins.currentSystem')
    nom build .#checks.$sys.invariant-module-dirs
    nom build .#checks.$sys.invariant-universe-features
    nom build .#checks.$sys.invariant-bindings-subdirs
    nom build .#checks.$sys.invariant-no-manual-imports

# -------------------------------------------------------------------------------
# ALIASES
# -------------------------------------------------------------------------------

# Shorthand: build and switch
bs host="darwin": (switch host)

# Shorthand: check and switch
cs host="darwin": check (switch host)

# Shorthand: update and switch
us host="darwin": update (switch host)

# Enter dev shell
dev shell="default":
    nix develop .#{{shell}}
