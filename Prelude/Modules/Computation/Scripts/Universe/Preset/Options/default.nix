# Preset - Tmux session presets for capability-complete workflows
#
# Each preset defines a tmux layout with panes that provide
# complete capability closure for a workflow domain.
{ lib, ... }:
{
  options.preset = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        description = lib.mkOption {
          type = lib.types.str;
          description = "What this preset is for";
        };
        panes = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Pane identifier";
              };
              cmd = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Command to run (empty = shell)";
              };
              watch = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Glob pattern to watch (runs cmd on change)";
              };
              dir = lib.mkOption {
                type = lib.types.str;
                default = ".";
                description = "Working directory for pane";
              };
              size = lib.mkOption {
                type = lib.types.int;
                default = 50;
                description = "Pane size percentage";
              };
              split = lib.mkOption {
                type = lib.types.enum [ "h" "v" ];
                default = "h";
                description = "Split direction (h=horizontal, v=vertical)";
              };
            };
          });
          description = "Pane definitions";
        };
      };
    });
    default = {};
    description = "Tmux session presets";
  };
}
