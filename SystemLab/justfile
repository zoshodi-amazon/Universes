# ===============================================================================
# UNIVERSES — Typed Device Configuration
# ===============================================================================
#
# Every command is a classified morphism (6-functor formalism):
#
#   ana-{cmd}   — anamorphism  — coalgebraic observation (f*, f!, Hom)
#   cata-{cmd}  — catamorphism — algebraic production (f*, f!)
#   hylo-{cmd}  — hylomorphism — tensor composite: ana then cata (⊗)
#
# Phase chain:
#   Identity → Platform → Network → Services → User → Workspace → Deploy
#   (Unit/⊤)   (ADT)      (Indexed)  (A → B)    (A×B)  (M A)       (IO)
#
# Types/ (Lean 4) → default.json → Types/IO/ (Nix IO executors)
# See AGENTS.md for full 6FF mapping.
#
# ===============================================================================

default:
    @just --list

# ===============================================================================
# ana- (Anamorphism) — Coalgebraic observations → CoTypes/
# ===============================================================================

# f! shriek pullback — CoIO: validate flake integrity
ana-check:
    @gum style --border normal --padding "0 1" "Checking flake"
    @nix flake check --show-trace 2>&1 | nom
    @gum style --foreground 82 "Check passed"

# f* pullback — CoProduct: show all flake outputs
ana-show:
    nix flake show

# f* pullback — CoProduct: eval any attribute path
ana-eval path:
    nix eval '.#{{path}}'

# f* pullback — CoProduct: eval as JSON
ana-eval-json path:
    nix eval --json '.#{{path}}' | jq

# Hom internal — CoInductive: list attribute names at path
ana-keys path:
    @nix eval --json '.#{{path}}' --apply 'builtins.attrNames' | jq -r '.[]'

# f! shriek pullback — CoHom: validate default.json against Lean schemas
ana-types-validate:
    @gum style --border normal --padding "0 1" "Validating $(gum style --foreground 212 'phase types')"
    @nix-shell -p lean4 --run "cd Types/IO && lake build validate && .lake/build/bin/validate ."
    @gum style --foreground 82 "All phases valid"

# --- Phase observations (f* pullback — CoProduct/{Phase}) ---

# f* pullback — CoProduct/Identity: observe nix settings, secrets
ana-identity:
    @nix eval '.#homeConfigurations.darwin.config.nix' --json 2>/dev/null | jq . || echo "Identity phase"

# f* pullback — CoProduct/Platform: observe boot, disk, hardware
ana-platform:
    @nix eval '.#nixosConfigurations' --apply 'builtins.attrNames' 2>/dev/null || echo "Platform phase"

# f* pullback — CoProduct/Network: observe firewall, SSH
ana-network:
    @nix eval '.#homeConfigurations.darwin.config.programs.ssh.matchBlocks' --apply 'builtins.attrNames' 2>/dev/null || echo "Network phase"

# f* pullback — CoProduct/Services: observe containers, daemons
ana-services:
    @echo "Services phase (nixos only)"

# f* pullback — CoProduct/User: observe shell, editor, tools
ana-user:
    @nix eval '.#homeConfigurations.darwin.config.programs' --apply 'builtins.attrNames' 2>/dev/null | head -20 || echo "User phase"

# f* pullback — CoProduct/Workspace: observe devShells
ana-workspace:
    @nix eval '.#devShells' --apply 'x: builtins.attrNames x.aarch64-darwin or {}' 2>/dev/null || echo "Workspace phase"

# f* pullback — CoProduct/Deploy: observe deployment targets
ana-deploy:
    @nix eval '.#homeConfigurations' --apply 'builtins.attrNames' && nix eval '.#nixosConfigurations' --apply 'builtins.attrNames'

# --- User sub-phase observations ---

# f* pullback — CoProduct/User/Identity
ana-user-identity:
    @echo "User identity: handled by IOMainPhase"

# f* pullback — CoProduct/User/Credentials
ana-user-credentials:
    @nix eval '.#homeConfigurations.darwin.config.programs.git.userName' 2>/dev/null || echo "Credentials phase"

# f* pullback — CoProduct/User/Shell
ana-user-shell:
    @nix eval '.#homeConfigurations.darwin.config.programs.zsh.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.fish.enable' 2>/dev/null

# f* pullback — CoProduct/User/Terminal
ana-user-terminal:
    @nix eval '.#homeConfigurations.darwin.config.programs.tmux.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.kitty.enable' 2>/dev/null

# f* pullback — CoProduct/User/Editor
ana-user-editor:
    @nix eval '.#homeConfigurations.darwin.config.programs.nixvim.enable' 2>/dev/null || echo "Editor phase"

# Hom internal — CoDependent: observe editor keymaps
ana-keymaps host="darwin":
    @nix eval '.#homeConfigurations.{{host}}.config.programs.nixvim.keymaps' 2>&1 \
        | grep -oE 'key = "[^"]+";.*desc = "[^"]+"' \
        | sed 's/key = "//; s/";.*desc = "/ → /; s/"$//'

# Hom internal — CoDependent: observe editor plugins
ana-plugins host="darwin":
    @nix eval --json '.#homeConfigurations.{{host}}.config.programs.nixvim.plugins' \
        --apply 'p: builtins.filter (n: n != "__unfix__") (builtins.attrNames p)' | jq -r '.[]'

# f* pullback — CoProduct/User/Comms
ana-user-comms:
    @nix eval '.#homeConfigurations.darwin.config.programs.opencode.enable' 2>/dev/null && nix eval '.#homeConfigurations.darwin.config.programs.awscli.enable' 2>/dev/null

# f* pullback — CoProduct/User/Packages
ana-user-packages:
    @nix eval '.#homeConfigurations.darwin.config.home.packages' --apply 'map (p: p.name or "unknown")' 2>/dev/null | head -20 || echo "Packages phase"

# --- Store/package observations ---

# f* pullback — CoIdentity: show store path size
ana-size path="./result":
    nix path-info -Sh {{path}}

# f* pullback — CoInductive: search nixpkgs
ana-search query:
    nix search nixpkgs {{query}}

# f* pullback — CoIdentity: show package meta
ana-info pkg:
    nix eval --json '{{pkg}}.meta' | jq

# Hom internal — CoInductive: list homeManager modules
ana-modules-home:
    @nix eval --json '.#modules.homeManager' --apply 'builtins.attrNames' | jq -r '.[]'

# Hom internal — CoInductive: list nixos modules
ana-modules-nixos:
    @nix eval --json '.#modules.nixos' --apply 'builtins.attrNames' | jq -r '.[]'

# f* pullback — CoIO: enter REPL
ana-repl:
    nix repl .#

# ===============================================================================
# cata- (Catamorphism) — Algebraic productions → Types/
# ===============================================================================

# f! shriek push — IO (Lake): build Lean type system
cata-types-build:
    @gum style --border normal --padding "0 1" "Building $(gum style --foreground 212 'Types')"
    @nix-shell -p lean4 --run "cd Types/IO && lake build"
    @gum style --foreground 82 "Types built"

# f! shriek push — Product/Deploy: build machine image
cata-build machine:
    @gum style --border normal --padding "0 1" "Building $(gum style --foreground 212 '{{machine}}')"
    @nom build .#{{machine}}-iso --print-out-paths
    @gum style --foreground 82 "Build complete"

# f* pushforward — Product/Deploy: switch home configuration
cata-switch host="darwin":
    @gum style --border normal --padding "0 1" "Switching to $(gum style --foreground 212 '{{host}}')"
    @nh home switch . -c {{host}}

# f* pushforward — Product/Deploy: flash ISO to USB
cata-flash machine disk:
    @gum style --border normal --foreground 196 --padding "0 1" "WARNING: This will erase {{disk}}"
    @gum confirm "Flash {{machine}} to {{disk}}?" && dd if=$(nom build .#{{machine}}-iso --print-out-paths)/iso/*.iso of={{disk}} bs=4M status=progress

# f* pushforward — IO: unmount disk volumes
cata-unmount disk:
    @gum style --foreground 212 "Unmounting {{disk}}"
    @diskutil unmountDisk {{disk}} 2>/dev/null || echo "Already unmounted"

# f* pushforward — Identity (flake.lock): update all inputs
cata-update:
    nix flake update

# f* pushforward — Identity: update specific input
cata-update-input input:
    nix flake update {{input}}

# f! shriek push — IO: garbage collect store
cata-gc days="7":
    nix-collect-garbage --delete-older-than {{days}}d

# f! shriek push — IO: optimize store
cata-optimize:
    nix store optimise

# f* pushforward — IO: sync repo to remote host
cata-sync-to host:
    @gum style --border normal --padding "0 1" "Syncing to $(gum style --foreground 212 '{{host}}')"
    @gum spin --spinner dot --title "Syncing..." -- rsync -avz --delete --filter=':- .gitignore' --exclude='.git/' ~/repos/Universes/ {{host}}:~/repos/Universes/
    @gum style --foreground 82 "Sync complete"

# f* pushforward — IO: SSH into deployed machine
cata-ssh machine user="":
    @gum style --foreground 212 "Connecting to {{machine}}"
    @if [ -z "{{user}}" ]; then ssh {{machine}}; else ssh {{user}}@{{machine}}; fi

# f* pushforward — IO: SSH into MicroVM via port forward
cata-ssh-microvm host user="root":
    @gum style --foreground 212 "SSH to MicroVM via {{host}}:2222"
    @ssh -J {{host}} -p 2222 {{user}}@localhost

# f* pushforward — IO: run package without installing
cata-run pkg *args:
    nix run {{pkg}} -- {{args}}

# f* pushforward — IO: run VM for testing
cata-vm machine:
    @gum style --foreground 212 "Starting VM: {{machine}}"
    @nix run .#{{machine}}-vm

# f* pushforward — IO: refresh AWS credentials
cata-ada:
    ada credentials update --account=043309350576 --provider=conduit --role=IibsAdminAccess-DO-NOT-DELETE 

cata-ada-once:
    ada credentials update --account=043309350576 --provider=conduit --role=IibsAdminAccess-DO-NOT-DELETE --once 

# ===============================================================================
# hylo- (Hylomorphism) — Tensor composites → Types/ ⊗ CoTypes/
# ===============================================================================

# ⊗ tensor — ana-types-validate ⊗ cata-switch
hylo-main host="darwin": ana-types-validate (cata-switch host)

# ⊗ tensor — cata-sync-to ⊗ cata-build (remote)
hylo-remote-build host machine:
    @gum style --border normal --padding "0 1" "Remote build $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just cata-sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nom build .#{{machine}}-iso --print-out-paths"

# ⊗ tensor — cata-sync-to ⊗ cata-switch (remote)
hylo-remote-switch host config="cloud-dev":
    @just cata-sync-to {{host}}
    @gum style --border normal --padding "0 1" "Switching $(gum style --foreground 212 '{{config}}') on $(gum style --foreground 212 '{{host}}')"
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && home-manager switch --flake .#{{config}}"
    @gum style --foreground 82 "Remote switch complete"

# ⊗ tensor — cata-sync-to ⊗ cata-vm (remote)
hylo-remote-vm host machine:
    @gum style --border normal --padding "0 1" "Remote VM $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just cata-sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run .#{{machine}}-vm"

# ⊗ tensor — cata-sync-to ⊗ cata-microvm (remote)
hylo-remote-microvm host machine:
    @gum style --border normal --padding "0 1" "MicroVM $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}')"
    @just cata-sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run .#{{machine}}-microvm"

# ⊗ tensor — cata-sync-to ⊗ remote nixos-anywhere install
hylo-remote-install host machine:
    @gum style --border normal --padding "0 1" "Installing $(gum style --foreground 212 '{{machine}}') on $(gum style --foreground 212 '{{host}}') via nixos-anywhere"
    @just cata-sync-to {{host}}
    @ssh -t {{host}} "source ~/.nix-profile/etc/profile.d/nix.sh && cd ~/repos/Universes && nix run github:nix-community/nixos-anywhere -- --flake .#{{machine}} root@localhost"

# ⊗ tensor — ana-eval ⊗ cata-run (enter dev shell)
hylo-dev shell="default":
    nix develop .#{{shell}}
