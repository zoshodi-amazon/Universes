# Universal flake commands for nushell

# List all flake outputs
export def "flake show" [] {
  nix flake show --json 2>&1 | from json
}

# List available hosts/configurations
export def "flake hosts" [] {
  nix eval --json '.#homeConfigurations' --apply 'builtins.attrNames' | from json
}

# List all modules by class
export def "flake modules" [] {
  nix eval --json '.#modules' --apply 'builtins.mapAttrs (k: v: builtins.attrNames v)' | from json | transpose class modules
}

# Eval any config path
export def "flake eval" [
  path: string                  # e.g. ".#homeConfigurations.cloud-dev.config.programs.nixvim"
  --json (-j)                   # output as json
  --keys (-k)                   # show only attribute names
] {
  let expr = if $keys { $"--apply 'builtins.attrNames'" } else { "" }
  let fmt = if $json { "--json" } else { "" }
  ^nix eval $fmt $path ...($expr | split row ' ' | where $it != "")
}

# List keymaps for a host
export def "flake keymaps" [
  host: string = "cloud-dev"
] {
  flake eval $".#homeConfigurations.($host).config.programs.nixvim.keymaps"
    | lines | str join ' ' 
    | parse -r 'key = "(?<key>[^"]+)".*?desc = "(?<desc>[^"]+)"'
}

# Build a flake output
export def "flake build" [
  target: string                # e.g. ".#homeConfigurations.cloud-dev.activationPackage"
  --dry (-d)                    # dry run
] {
  if $dry {
    nix build $target --dry-run
  } else {
    nix build $target
  }
}

# Switch home-manager config
export def "flake switch" [
  host: string = "cloud-dev"
] {
  home-manager switch --flake $".#($host)"
}

# Run flake checks
export def "flake check" [
  --all (-a)                    # all systems
] {
  if $all {
    nix flake check --all-systems
  } else {
    nix flake check
  }
}

# Update flake inputs
export def "flake update" [
  input?: string                # specific input to update
] {
  if $input != null {
    nix flake update $input
  } else {
    nix flake update
  }
}

# Enter dev shell
export def "flake dev" [
  shell: string = "default"
] {
  nix develop $".#($shell)"
}

# Search nixpkgs
export def "nix search" [
  query: string
  --limit (-l): int = 20
] {
  ^nix search nixpkgs $query --json | from json | transpose name info | first $limit
}

# Show package info
export def "nix info" [
  pkg: string                   # e.g. "nixpkgs#ripgrep"
] {
  nix eval --json $"($pkg).meta" | from json
}

# Run a package without installing
export def "nix run" [
  pkg: string                   # e.g. "nixpkgs#cowsay"
  ...args: string
] {
  ^nix run $pkg -- ...$args
}

# Garbage collect
export def "nix gc" [
  --older-than (-o): string = "7d"
] {
  nix-collect-garbage --delete-older-than $older_than
}

# Show store path size
export def "nix size" [
  path?: string
] {
  if $path != null {
    nix path-info -Sh $path
  } else {
    nix path-info -Sh ./result
  }
}
