{ lib, ... }:
{
  options.lab.layout = {
    preset = lib.mkOption {
      type = lib.types.enum [ "explore" "compare" "export" "monitor" "custom" ];
      default = "explore";
      description = "Tmux layout preset";
    };
    panes = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          command = lib.mkOption { type = lib.types.str; };
          size = lib.mkOption { type = lib.types.int; default = 50; };
        };
      });
      default = [];
      description = "Custom pane configuration";
    };
  };
}
