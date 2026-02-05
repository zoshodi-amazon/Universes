{ lib, ... }:
let
  transformType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.str;
        description = "Transform type (domain-specific)";
      };
      params = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Transform parameters";
      };
    };
  };
in
{
  options.lab.session = {
    path = lib.mkOption {
      type = lib.types.str;
      default = ".lab/session.json";
      description = "Session state file path";
    };
    current = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Current asset ID";
    };
    stack = lib.mkOption {
      type = lib.types.listOf transformType;
      default = [];
      description = "Transform stack (applied in order)";
    };
    undoPosition = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Position in history for undo/redo";
    };
    mode = lib.mkOption {
      type = lib.types.enum [ "browse" "edit" "preview" "command" ];
      default = "browse";
      description = "Current TUI mode";
    };
  };
}
