# NixBrowser Artifact — typed option space for hardened Firefox
# Hardening is always-max. Only user-facing dials exposed.
{ lib, ... }:
{
  options.browser = {
    enable = lib.mkEnableOption "Hardened Firefox browser";
    search.default = lib.mkOption {
      type = lib.types.enum [ "DuckDuckGo" "Startpage" "SearXNG" ];
      default = "DuckDuckGo";
      description = "Default search engine";
    };
  };
}
