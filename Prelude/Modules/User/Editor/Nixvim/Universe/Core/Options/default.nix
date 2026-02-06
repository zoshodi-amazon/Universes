# Core nixvim options
{ lib, ... }:
{
  options.nixvim = {
    enable = lib.mkEnableOption "nixvim editor";
    colorscheme = lib.mkOption { type = lib.types.str; default = "tokyonight"; };
    leader = lib.mkOption { type = lib.types.str; default = " "; };
    lineNumbers = lib.mkOption { type = lib.types.bool; default = true; };
    relativeNumbers = lib.mkOption { type = lib.types.bool; default = false; };
    tabWidth = lib.mkOption { type = lib.types.int; default = 2; };
    keymaps = lib.mkOption { type = lib.types.attrsOf (lib.types.listOf lib.types.attrs); default = {}; };
    plugins = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; };
    extraPluginConfigs = lib.mkOption { type = lib.types.attrsOf lib.types.attrs; default = {}; };
    env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  };
}
