{ lib, ... }:
let
  capabilityType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Capability identifier";
      };
      weight = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Priority weight (0.0-1.0)";
      };
      required = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Must be satisfied (hard constraint)";
      };
    };
  };

  candidateType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Tool/package name";
      };
      capabilities = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Capabilities this tool provides";
      };
      source = lib.mkOption {
        type = lib.types.enum [ "nixpkgs" "flake" "custom" ];
        default = "nixpkgs";
        description = "Where to find this tool";
      };
    };
  };
in
{
  options.discover = {
    capabilities = lib.mkOption {
      type = lib.types.listOf capabilityType;
      default = [];
      description = "Required capability space";
    };
    candidates = lib.mkOption {
      type = lib.types.listOf candidateType;
      default = [];
      description = "Tool candidates to evaluate";
    };
    selected = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Selected tools (frozen)";
    };
  };
}
