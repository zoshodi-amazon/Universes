# Shell — global instantiation
# Exports to flake.modules.homeManager.{shell,zsh,fish,nushell,direnv}
{ config, lib, ... }:
let
  env = config.shell.env;
  zsh = config.shell.zsh;
  fish = config.shell.fish;
  nu = config.shell.nushell;
  direnv = config.shell.direnv;
  aliasLines = lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "alias ${n} = ${v}") nu.aliases);
  pathStr = lib.concatStringsSep ", " (map (p: "\"${p}\"") nu.paths);
in
{
  config.flake.modules.homeManager.shell = {
    home.sessionVariables = {
      EDITOR = env.EDITOR;
      VISUAL = env.VISUAL;
      KEYTIMEOUT = toString env.KEYTIMEOUT;
    };
    programs.starship.enable = true;
  };

  config.flake.modules.homeManager.zsh = lib.mkIf zsh.enable {
    programs.zsh = {
      enable = true;
      shellAliases = zsh.aliases;
      initContent = ''
        ${lib.concatMapStringsSep "\n" (p: "export PATH=\"${p}:$PATH\"") zsh.paths}
        bindkey -v
        ${zsh.initExtra}
      '';
    };
    programs.starship.enableZshIntegration = true;
  };

  config.flake.modules.homeManager.fish = lib.mkIf fish.enable {
    programs.fish = {
      enable = true;
      shellAliases = fish.aliases;
      interactiveShellInit = ''
        ${lib.concatMapStringsSep "\n" (p: "fish_add_path ${p}") fish.paths}
        fish_vi_key_bindings
        ${fish.interactiveShellInit}
      '';
      shellInit = fish.initExtra;
    };
    programs.starship.enableFishIntegration = true;
  };

  config.flake.modules.homeManager.nushell = lib.mkIf nu.enable {
    programs.nushell = {
      enable = true;
      configFile.text = ''
        $env.config = { show_banner: false, edit_mode: vi }
        ${aliasLines}
        ${nu.configExtra}
      '';
      envFile.text = ''
        $env.PATH = ($env.PATH | split row (char esep) | prepend [${pathStr}])
        ${nu.envExtra}
      '';
    };
    programs.starship.enableNushellIntegration = true;
  };

  config.flake.modules.homeManager.direnv = lib.mkIf direnv.enable {
    programs.direnv = { enable = true; nix-direnv.enable = direnv.nix-direnv.enable; };
  };
}
