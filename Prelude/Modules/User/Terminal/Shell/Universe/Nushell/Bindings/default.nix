{ config, lib, ... }:
let
  cfg = config.shell.nushell;
  aliasLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "alias ${n} = ${v}") cfg.aliases);
  pathStr = lib.concatStringsSep ", " (map (p: "\"${p}\"") cfg.paths);
in
{
  config.flake.modules.homeManager.nushell = lib.mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      configFile.text = ''
        $env.config = { show_banner: false, edit_mode: vi }
        ${aliasLines}
        ${cfg.configExtra}
      '';
      envFile.text = ''
        $env.PATH = ($env.PATH | split row (char esep) | prepend [${pathStr}])
        ${cfg.envExtra}
      '';
    };
    programs.starship.enableNushellIntegration = true;
  };
}
