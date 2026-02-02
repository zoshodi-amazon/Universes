# Instances: wire options to nixvim flake module
{ config, lib, inputs, ... }:
let 
  cfg = config.nixvim;
  buildExtraPlugins = pkgs: lib.mapAttrsToList (name: spec: {
    plugin = pkgs.vimUtils.buildVimPlugin {
      inherit name;
      src = pkgs.fetchFromGitHub {
        inherit (spec) owner repo rev sha256;
      };
    };
    config = spec.config or "";
  }) cfg.extraPluginConfigs;
in
{
  config.flake.modules.homeManager.nixvim = lib.mkIf cfg.enable {
    imports = [ inputs.nixvim.homeModules.nixvim ];
    programs.nixvim = { pkgs, ... }: {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      globals.mapleader = cfg.leader;
      colorschemes.${cfg.colorscheme}.enable = true;
      opts = {
        number = cfg.lineNumbers;
        relativenumber = cfg.relativeNumbers;
        tabstop = cfg.tabWidth;
        shiftwidth = cfg.tabWidth;
        expandtab = true;
        smartindent = true;
        foldmethod = "expr";
        foldexpr = "v:lua.vim.treesitter.foldexpr()";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;
      };
      keymaps = lib.flatten (lib.attrValues cfg.keymaps);
      plugins = lib.mkMerge (lib.attrValues cfg.plugins);
      extraPlugins = buildExtraPlugins pkgs;
    };
  };
}
