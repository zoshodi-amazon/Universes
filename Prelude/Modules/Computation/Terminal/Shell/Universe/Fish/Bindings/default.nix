{ config, lib, ... }:
let cfg = config.shell.fish; in
{
  config.flake.modules.homeManager.fish = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = cfg.aliases;
      interactiveShellInit = ''
        ${lib.concatMapStringsSep "\n" (p: "fish_add_path ${p}") cfg.paths}
        fish_vi_key_bindings
        ${cfg.interactiveShellInit}
      '';
      shellInit = cfg.initExtra;
    };
    programs.starship.enableFishIntegration = true;
  };
}
