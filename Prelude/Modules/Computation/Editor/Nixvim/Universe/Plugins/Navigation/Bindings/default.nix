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

  # Keymaps co-located with plugin
  config.nixvim.keymaps.navigation = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>if"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
    { mode = "n"; key = "<leader>ig"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
    { mode = "n"; key = "<leader>ib"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Find buffers"; }
    { mode = "n"; key = "<leader>sd"; action = "<cmd>Telescope diagnostics<cr>"; options.desc = "Diagnostics"; }
    { mode = "n"; key = "<leader>mh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help tags"; }
    { mode = "n"; key = "<leader>mk"; action = "<cmd>Telescope keymaps<cr>"; options.desc = "Search keymaps"; }
    { mode = "n"; key = "<leader>mm"; action = "<cmd>Telescope man_pages<cr>"; options.desc = "Man pages"; }
    { mode = "n"; key = "<leader>e"; action = "<cmd>Oil<cr>"; options.desc = "File explorer"; }
    { mode = "n"; key = "<leader>it"; action = "<cmd>NvimTreeToggle<cr>"; options.desc = "Toggle file tree"; }
    { mode = "n"; key = "<leader>ia"; action.__raw = "function() require('harpoon'):list():add() end"; options.desc = "Harpoon add"; }
    { mode = "n"; key = "<leader>ih"; action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end"; options.desc = "Harpoon menu"; }
    { mode = "n"; key = "<leader>i1"; action.__raw = "function() require('harpoon'):list():select(1) end"; options.desc = "Harpoon 1"; }
    { mode = "n"; key = "<leader>i2"; action.__raw = "function() require('harpoon'):list():select(2) end"; options.desc = "Harpoon 2"; }
    { mode = "n"; key = "<leader>i3"; action.__raw = "function() require('harpoon'):list():select(3) end"; options.desc = "Harpoon 3"; }
    { mode = "n"; key = "<leader>i4"; action.__raw = "function() require('harpoon'):list():select(4) end"; options.desc = "Harpoon 4"; }
  ];
}
