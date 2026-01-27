# Direnv Bindings
{ config, lib, ... }:
let cfg = config.shell.direnv; in
{
  config.flake.modules.homeManager.direnv = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = cfg.nix-direnv.enable;
    };
  };
}
