# Firefox Options
{ lib, ... }:
{
  options.browsers.firefox = {
    enable = lib.mkEnableOption "Firefox browser";
    defaultBrowser = lib.mkOption { type = lib.types.bool; default = true; };
    extensions = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    settings = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
    search = {
      default = lib.mkOption { type = lib.types.str; default = "DuckDuckGo"; };
      privateDefault = lib.mkOption { type = lib.types.str; default = "DuckDuckGo"; };
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          isDefault = lib.mkOption { type = lib.types.bool; default = false; };
          settings = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
        };
      });
      default = {};
    };
  };
}
