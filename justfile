# ===============================================================================
# UNIVERSES - Dendritic Nix Configuration System
# ===============================================================================
#
# NAME
#     justfile - Phase pipeline interface (all recipes map to IOMainPhase)
#
# SYNOPSIS
#     just <recipe> [arguments...]
#     just --list
#
# PHASES
#     Identity → Platform → Network → Services → User → Workspace → Deploy
#     Types/ (Lean 4) → default.json → Monads/ (Nix)
#
# ===============================================================================
#
# DESCRIPTION
#     Single source of truth for all Universes operations.
#     Organized by capability, not implementation.
#
#     BUILD       - Compile and validate
#     DEPLOY      - Flash and connect to machines
#     SYNC        - Remote build operations
#     HOME        - Home configuration management
#     FLAKE       - Flake inspection and management
#     STORE       - Nix store operations
#     SOVEREIGNTY - Pipeline monads
#
# PHILOSOPHY
#     Index on CAPABILITY, not IMPLEMENTATION.
#     Types define the metric space (what), Monads produce outputs (how).
#     See AGENTS.md for full ontology.
#
# ===============================================================================

default:
    @just --list

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
    @gum confirm "Flash {{machine}} to {{disk}}?" && dd if=$(nom build .#{{machine}}-iso --print-out-paths)/iso/*.iso of={{disk}} bs=4M status=progress

# Unmount all volumes on a disk (required before flashing)
# ARGS: disk - target disk (e.g., /dev/disk4)
unmount disk:
    @gum style --foreground 212 "Unmounting {{disk}}"
    @diskutil unmountDisk {{disk}} 2>/dev/null || echo "Already unmounted"

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
    @gum spin --spinner dot --title "Syncing..." -- rsync -avz --delete --filter=':- .gitignore' --exclude='.git/' ~/repos/Universes/ {{host}}:~/repos/Universes/
    @gum style --foreground 82 "Sync complete"

# Build on remote host and copy ISO back to ~/Downloads/<machine>.iso
# ARGS: host - SSH host, machine - name of machine
remote-build host machine:
    @gum style --border normal --padding "0 1" "Remote build $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nom build .#{{machine}}-iso --print-out-paths"

# Build VM on remote host
# ARGS: host - SSH host, machine - name of machine
remote-build-vm host machine:
    @gum style --border normal --padding "0 1" "Remote build VM $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run .#{{machine}}-vm"

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

# -------------------------------------------------------------------------------
# PIPELINE — IOMainPhase (7-phase matter chain)
# -------------------------------------------------------------------------------

# IOMainPhase — full pipeline: validate + switch
main host="darwin": types-validate (switch host)

# Build Lean type system
types-build:
    @gum style --border normal --padding "0 1" "Building $(gum style --foreground 212 'Types')"
    @cd Modules/Types && lake build
    @gum style --foreground 82 "Types built"

# Validate default.json against Lean schemas
types-validate:
    @gum style --border normal --padding "0 1" "Validating $(gum style --foreground 212 'phase configs')"
    @cd Modules/Types && lake env lean --run Default.lean ../Monads
    @gum style --foreground 82 "All phases valid"

# --- Top-level phases (BEC → QGP) ---

# IOIdentityPhase (BEC) — nix settings, secrets
identity:
    @nix eval '.#homeConfigurations.darwin.config.nix' --json 2>/dev/null | jq . || echo "Identity phase"

# IOPlatformPhase (Crystalline) — boot, disk, hardware, display
platform:
    @nix eval '.#nixosConfigurations' --apply 'builtins.attrNames' 2>/dev/null || echo "Platform phase"

# IONetworkPhase (Liquid Crystal) — firewall, SSH
network:
    @nix eval '.#homeConfigurations.darwin.config.programs.ssh.matchBlocks' --apply 'builtins.attrNames' 2>/dev/null || echo "Network phase"

# IOServicesPhase (Liquid) — containers, servers
services:
    @echo "Services phase (nixos only)"

# IOUserPhase (Gas) — user config (7 sub-phases)
user:
    @nix eval '.#homeConfigurations.darwin.config.programs' --apply 'builtins.attrNames' 2>/dev/null | head -20 || echo "User phase"

# IOWorkspacePhase (Plasma) — devShells, labs
workspace:
    @nix eval '.#devShells' --apply 'x: builtins.attrNames x.aarch64-darwin or {}' 2>/dev/null || echo "Workspace phase"

# IOMainPhase (QGP) — deploy targets
main-deploy:
    @nix eval '.#homeConfigurations' --apply 'builtins.attrNames' && nix eval '.#nixosConfigurations' --apply 'builtins.attrNames'

# --- User sub-phases ---

# IOIdentityPhase (BEC) — user identity
user-identity:
    @echo "User identity: handled by IOMainPhase"

# IOCredentialsPhase (Crystalline) — git, signing
user-credentials:
    @nix eval '.#homeConfigurations.darwin.config.programs.git.userName' 2>/dev/null || echo "Credentials phase"

# IOShellPhase (Liquid Crystal) — zsh, fish, nushell, direnv
user-shell:
    @nix eval '.#homeConfigurations.darwin.config.programs.zsh.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.fish.enable' 2>/dev/null

# IOTerminalPhase (Liquid) — tmux, kitty
user-terminal:
    @nix eval '.#homeConfigurations.darwin.config.programs.tmux.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.kitty.enable' 2>/dev/null

# IOEditorPhase (Gas) — nixvim
user-editor:
    @nix eval '.#homeConfigurations.darwin.config.programs.nixvim.enable' 2>/dev/null || echo "Editor phase"

# IOCommsPhase (Plasma) — browser, mail, AI, cloud
user-comms:
    @nix eval '.#homeConfigurations.darwin.config.programs.opencode.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.awscli.enable' 2>/dev/null

# IOPackagesPhase (QGP) — corePackages
user-packages:
    @nix eval '.#homeConfigurations.darwin.config.home.packages' --apply 'map (p: p.name or "unknown")' 2>/dev/null | head -20 || echo "Packages phase"

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
