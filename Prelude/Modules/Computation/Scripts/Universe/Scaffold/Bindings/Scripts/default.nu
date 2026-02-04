#!/usr/bin/env nu

# Scaffold module or feature from frozen template
# Usage: default.nu <config_path>
# Config: { mode: "module" | "feature", path: "<path>", name?: "<feature_name>" }

def main [config_path: string] {
  let cfg = (open $config_path)
  
  match $cfg.mode {
    "module" => {
      let path = $cfg.path
      if ($path | path exists) {
        print $"Error: ($path) already exists"
        exit 1
      }
      
      let module_name = ($path | path basename)
      
      mkdir $"($path)/Env"
      mkdir $"($path)/Instances"
      mkdir $"($path)/Universe"
      
      "{ ... }: { }" | save $"($path)/default.nix"
      
      "{ config, lib, ... }:
{
  # ENV var aggregation from Options
}" | save $"($path)/Env/default.nix"
      
      "{ config, lib, pkgs, ... }:
{
  # flake.modules.* exports
}" | save $"($path)/Instances/default.nix"
      
      "{ ... }: { }" | save $"($path)/Universe/default.nix"
      
      $"# ($module_name)

<One-line description of capability>

## Features

| Feature | Capability |
|---------|------------|

## Options

See `just options ($path)`
" | save $"($path)/README.md"
      
      print $"Created module: ($path)"
    }
    "feature" => {
      let module = $cfg.path
      let name = $cfg.name
      let feature_path = $"($module)/Universe/($name)"
      
      if ($feature_path | path exists) {
        print $"Error: ($feature_path) already exists"
        exit 1
      }
      
      if not ($module | path exists) {
        print $"Error: Module ($module) does not exist"
        exit 1
      }
      
      mkdir $"($feature_path)/Options"
      mkdir $"($feature_path)/Bindings"
      
      "{ ... }: { }" | save $"($feature_path)/default.nix"
      
      let module_name = ($module | path basename | str downcase)
      let feature_lower = ($name | str downcase)
      
      $"{ lib, ... }:
{
  options.($module_name).($feature_lower) = {
    enable = lib.mkEnableOption \"($name)\";
  };
}" | save $"($feature_path)/Options/default.nix"
      
      $"{ config, lib, ... }:
let
  cfg = config.($module_name).($feature_lower);
in
{
  config = lib.mkIf cfg.enable {
    # Wire Options to implementations
  };
}" | save $"($feature_path)/Bindings/default.nix"
      
      print $"Created feature: ($feature_path)"
    }
  }
}
