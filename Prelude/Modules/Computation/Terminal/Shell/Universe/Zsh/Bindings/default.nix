{ config, lib, ... }:
let cfg = config.shell.zsh; in
{
  config.flake.modules.homeManager.zsh = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      shellAliases = cfg.aliases;
      initExtra = ''
        ${lib.concatMapStringsSep "\n" (p: "export PATH=\"${p}:$PATH\"") cfg.paths}
        bindkey -v
        ${cfg.initExtra}
      '';
    };
    programs.starship.enableZshIntegration = true;
  };
}
