# NixNvimCore Artifact — core editor options
{ lib, ... }:
{
  options.nixvim = {
    enable = lib.mkEnableOption "nixvim editor";
    colorscheme = lib.mkOption { type = lib.types.str; default = "tokyonight"; description = "Colorscheme"; };
    leader = lib.mkOption { type = lib.types.str; default = " "; description = "Leader"; };
    lineNumbers = lib.mkOption { type = lib.types.bool; default = true; description = "Line numbers"; };
    relativeNumbers = lib.mkOption { type = lib.types.bool; default = false; description = "Relative numbers"; };
    tabWidth = lib.mkOption { type = lib.types.int; default = 2; description = "Tab width"; };
    keymaps = lib.mkOption { type = lib.types.attrsOf (lib.types.listOf lib.types.attrs); default = {}; description = "Keymaps"; };
    plugins = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; description = "Plugins"; };
    extraPluginConfigs = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; description = "Extra plugin configs"; };
    extraConfigLua = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Extra config lua"; };
    globals = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; description = "Globals"; };
    extraPackages = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Extra packages"; };
    env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Env"; };
  };
}
