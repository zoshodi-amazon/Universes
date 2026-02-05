{ lib, ... }:
let
  presetType = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; };
      knobs = lib.mkOption { type = lib.types.attrsOf lib.types.float; default = {}; };
      transforms = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
    };
  };
in
{
  options.lab.presets = {
    global = lib.mkOption {
      type = lib.types.attrsOf presetType;
      default = {};
      description = "Global presets (all domains)";
    };
    domain = lib.mkOption {
      type = lib.types.attrsOf presetType;
      default = {};
      description = "Domain-specific presets";
    };
    user = lib.mkOption {
      type = lib.types.attrsOf presetType;
      default = {};
      description = "User presets (in .lab/presets/)";
    };
  };
}
