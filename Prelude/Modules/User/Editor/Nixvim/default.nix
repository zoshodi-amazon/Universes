# Nixvim — global instantiation
{ config, lib, inputs, ... }:
let
  cfg = config.nixvim;
  buildExtraPlugins = pkgs: lib.mapAttrsToList (name: spec: {
    plugin = pkgs.vimUtils.buildVimPlugin { inherit name; src = pkgs.fetchFromGitHub { inherit (spec) owner repo rev sha256; }; };
    config = spec.config or "";
  }) cfg.extraPluginConfigs;
  buildGlobals = lib.foldlAttrs (acc: _: v: acc // v) {} cfg.globals;
  buildExtraConfigLua = lib.concatStringsSep "\n" (lib.attrValues cfg.extraConfigLua);
in
{
  config.flake.modules.homeManager.nixvim = lib.mkIf cfg.enable {
    imports = [ inputs.nixvim.homeModules.nixvim ];
    programs.nixvim = { pkgs, ... }: {
      enable = true; defaultEditor = true; viAlias = true; vimAlias = true;
      globals = { mapleader = cfg.leader; } // buildGlobals;
      colorschemes.${cfg.colorscheme}.enable = true;
      opts = {
        number = cfg.lineNumbers; relativenumber = cfg.relativeNumbers;
        tabstop = cfg.tabWidth; shiftwidth = cfg.tabWidth; expandtab = true; smartindent = true;
        foldmethod = "expr"; foldexpr = "v:lua.vim.treesitter.foldexpr()"; foldlevel = 99; foldlevelstart = 99; foldenable = true;
      };
      keymaps = lib.flatten (lib.attrValues cfg.keymaps);
      plugins = lib.mkMerge (lib.attrValues cfg.plugins);
      extraPlugins = buildExtraPlugins pkgs;
      extraConfigLua = buildExtraConfigLua;
      extraPackages = map (name: config.perSystem.packages.${name} or pkgs.${name}) cfg.extraPackages;
    };
  };
}
