# Navigation plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.navigation = lib.mkIf config.nixvim.enable {
    telescope = {
      enable = true;
      settings.defaults = {
        vimgrep_arguments = [
          "rg" "--color=never" "--no-heading" "--with-filename"
          "--line-number" "--column" "--smart-case" "--hidden"
          "--glob" "!.git/*"
        ];
        file_ignore_patterns = [ "^.git/" ];
      };
      settings.pickers.find_files = {
        find_command = [ "rg" "--files" "--hidden" "--glob" "!.git/*" ];
      };
    };
    oil.enable = true;
    nvim-tree.enable = true;
    yazi.enable = true;
    harpoon.enable = true;
    treesitter = {
      enable = true;
      folding.enable = true;
    };
  };
}
