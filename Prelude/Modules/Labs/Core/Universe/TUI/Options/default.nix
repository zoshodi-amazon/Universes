{ lib, ... }:
{
  options.lab.tui = {
    domain = lib.mkOption {
      type = lib.types.enum [ "audio" "video" "3d" "data" ];
      default = "audio";
      description = "Lab domain (determines available capabilities)";
    };
    justfile = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Path to domain-specific justfile";
    };
    preview = {
      mode = lib.mkOption {
        type = lib.types.enum [ "split" "inline" "external" ];
        default = "split";
        description = "Preview display mode";
      };
      refresh = lib.mkOption {
        type = lib.types.enum [ "live" "on-demand" ];
        default = "live";
        description = "Preview refresh strategy";
      };
    };
    theme = {
      primary = lib.mkOption {
        type = lib.types.str;
        default = "212";
        description = "Primary color (ANSI 256)";
      };
      secondary = lib.mkOption {
        type = lib.types.str;
        default = "82";
        description = "Secondary color (ANSI 256)";
      };
    };
  };
}
