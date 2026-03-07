# IOShellPhase (Liquid Crystal) — shell environment, zsh, fish, nushell, direnv, starship
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ../../default.json);
  local =
    if builtins.pathExists ../../local.json then
      builtins.fromJSON (builtins.readFile ../../local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  shell = cfg.shell;
  env = shell.env;
  aliases = shell.aliases;
  zsh = shell.zsh;
  fish = shell.fish;
  nu = shell.nushell;
  direnv = shell.direnv;
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
      shellAliases = aliases;
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
      shellAliases = aliases;
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
      configFile.text = "$env.config = { show_banner: false, edit_mode: vi }\n${
        lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "alias ${n} = ${v}") aliases)
      }\n${nu.configExtra}";
      envFile.text = "$env.PATH = ($env.PATH | split row (char esep) | prepend [${
        lib.concatStringsSep ", " (map (p: "\"${p}\"") nu.paths)
      }])\n${nu.envExtra}";
    };
    programs.starship.enableNushellIntegration = true;
  };
  config.flake.modules.homeManager.direnv = lib.mkIf direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = direnv.nixDirenv;
    };
  };
}
