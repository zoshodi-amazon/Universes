# AI — global instantiation
# OpenCode agent with programs.opencode home-manager module
{ config, lib, ... }:
let
  cfg = config.ai.opencode;
  providerSettings = lib.optionalAttrs (cfg.provider == "amazon-bedrock") {
    provider.amazon-bedrock.options = {
      inherit (cfg) region profile;
    } // lib.optionalAttrs (cfg.endpoint != "") {
      inherit (cfg) endpoint;
    };
  };
in
{
  config.flake.modules.homeManager.ai = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = providerSettings // cfg.extraSettings;
      rules = cfg.rules;
    };
  };
}
