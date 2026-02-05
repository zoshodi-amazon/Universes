{ lib, ... }:
let
  assetType = lib.types.submodule {
    options = {
      id = lib.mkOption {
        type = lib.types.str;
        description = "Unique asset identifier";
      };
      name = lib.mkOption {
        type = lib.types.str;
        description = "Display name";
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "File path";
      };
      source = lib.mkOption {
        type = lib.types.enum [ "url" "file" "generated" ];
        description = "How asset was acquired";
      };
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Asset tags for organization";
      };
    };
  };

  historyEntryType = lib.types.submodule {
    options = {
      assetId = lib.mkOption {
        type = lib.types.str;
        description = "Asset this history entry belongs to";
      };
      timestamp = lib.mkOption {
        type = lib.types.str;
        description = "ISO 8601 timestamp";
      };
      action = lib.mkOption {
        type = lib.types.enum [ "create" "transform" "delete" "restore" ];
        description = "Action performed";
      };
      state = lib.mkOption {
        type = lib.types.attrs;
        description = "State snapshot (JSON-serializable)";
      };
    };
  };
in
{
  options.lab.library = {
    path = lib.mkOption {
      type = lib.types.str;
      default = ".lab/library.db";
      description = "SQLite database path";
    };
    assets = lib.mkOption {
      type = lib.types.listOf assetType;
      default = [];
      description = "Asset catalog";
    };
    history = lib.mkOption {
      type = lib.types.listOf historyEntryType;
      default = [];
      description = "Full history for undo/redo";
    };
  };
}
