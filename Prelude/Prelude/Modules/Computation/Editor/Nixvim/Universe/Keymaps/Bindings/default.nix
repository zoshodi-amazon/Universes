# Keymap bindings
{ ... }:
{
  config.nixvim.keymaps = {
    core = [
      { mode = "i"; key = "jk"; action = "<Esc>"; options.desc = "Exit insert mode"; }
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to bottom window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to top window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }
    ];
    navigation = [
      { mode = "n"; key = "<leader>e"; action = "<cmd>Oil<cr>"; options.desc = "Open Oil file browser"; }
      { mode = "n"; key = "<leader>t"; action = "<cmd>NvimTreeToggle<cr>"; options.desc = "Toggle file tree"; }
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Find buffers"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help tags"; }
    ];
    lsp = [
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<cr>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gr"; action = "<cmd>lua vim.lsp.buf.references()<cr>"; options.desc = "Go to references"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<cr>"; options.desc = "Hover documentation"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; options.desc = "Code actions"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; options.desc = "Rename symbol"; }
    ];
    folds = [
      { mode = "n"; key = "za"; action = "za"; options.desc = "Toggle fold"; }
      { mode = "n"; key = "zR"; action = "zR"; options.desc = "Open all folds"; }
      { mode = "n"; key = "zM"; action = "zM"; options.desc = "Close all folds"; }
      { mode = "n"; key = "zo"; action = "zo"; options.desc = "Open fold"; }
      { mode = "n"; key = "zc"; action = "zc"; options.desc = "Close fold"; }
      { mode = "n"; key = "zj"; action = "zj"; options.desc = "Next fold"; }
      { mode = "n"; key = "zk"; action = "zk"; options.desc = "Previous fold"; }
    ];
    whichKey = [
      { mode = "n"; key = "<leader>?"; action = "<cmd>Telescope keymaps<cr>"; options.desc = "Search keymaps"; }
    ];
  };
}
