# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let cfg = config.browsers.firefox; in
{
  options.browsers.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.browsers.env = lib.mkIf cfg.enable {
    FIREFOX_ENABLED = lib.boolToString cfg.enable;
    FIREFOX_DEFAULT_BROWSER = lib.boolToString cfg.defaultBrowser;
    FIREFOX_SEARCH_DEFAULT = cfg.search.default;
  };
}
