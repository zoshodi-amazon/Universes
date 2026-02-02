# Keymap bindings - organized ontologically
{ ... }:
{
  config.nixvim.keymaps = {
    # Core vim motions (non-leader)
    core = [
      { mode = "i"; key = "jk"; action = "<Esc>"; options.desc = "Exit insert mode"; }
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to bottom window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to top window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<cr>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gr"; action = "<cmd>lua vim.lsp.buf.references()<cr>"; options.desc = "Go to references"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<cr>"; options.desc = "Hover documentation"; }
      { mode = "n"; key = "za"; action = "za"; options.desc = "Toggle fold"; }
      { mode = "n"; key = "zR"; action = "zR"; options.desc = "Open all folds"; }
      { mode = "n"; key = "zM"; action = "zM"; options.desc = "Close all folds"; }
      { mode = "n"; key = "zo"; action = "zo"; options.desc = "Open fold"; }
      { mode = "n"; key = "zc"; action = "zc"; options.desc = "Close fold"; }
      { mode = "n"; key = "zj"; action = "zj"; options.desc = "Next fold"; }
      { mode = "n"; key = "zk"; action = "zk"; options.desc = "Previous fold"; }
    ];

    # <leader>c → Computation (code actions, format, eval, check)
    computation = [
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; options.desc = "Code actions"; }
      { mode = "n"; key = "<leader>cf"; action = "<cmd>lua vim.lsp.buf.format()<cr>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "<leader>cr"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; options.desc = "Rename symbol"; }
      { mode = "n"; key = "<leader>cb"; action = "<cmd>!nix build<cr>"; options.desc = "Nix build"; }
      { mode = "n"; key = "<leader>cc"; action = "<cmd>!nix flake check<cr>"; options.desc = "Nix flake check"; }
      { mode = "n"; key = "<leader>ce"; action = "<cmd>!nix eval<cr>"; options.desc = "Nix eval"; }
      { mode = "n"; key = "<leader>cR"; action = "<cmd>terminal nix repl<cr>"; options.desc = "Nix REPL"; }
    ];

    # <leader>i → Information (files, buffers, grep, git)
    information = [
      { mode = "n"; key = "<leader>if"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>ig"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>ib"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Find buffers"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Oil<cr>"; options.desc = "File explorer"; }
      { mode = "n"; key = "<leader>it"; action = "<cmd>NvimTreeToggle<cr>"; options.desc = "Toggle file tree"; }
      { mode = "n"; key = "<leader>ia"; action.__raw = "function() require('harpoon'):list():add() end"; options.desc = "Harpoon add"; }
      { mode = "n"; key = "<leader>ih"; action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end"; options.desc = "Harpoon menu"; }
      { mode = "n"; key = "<leader>i1"; action.__raw = "function() require('harpoon'):list():select(1) end"; options.desc = "Harpoon 1"; }
      { mode = "n"; key = "<leader>i2"; action.__raw = "function() require('harpoon'):list():select(2) end"; options.desc = "Harpoon 2"; }
      { mode = "n"; key = "<leader>i3"; action.__raw = "function() require('harpoon'):list():select(3) end"; options.desc = "Harpoon 3"; }
      { mode = "n"; key = "<leader>i4"; action.__raw = "function() require('harpoon'):list():select(4) end"; options.desc = "Harpoon 4"; }
    ];

    # <leader>s → Signal (diagnostics, notifications, logs)
    signal = [
      { mode = "n"; key = "<leader>sd"; action = "<cmd>Telescope diagnostics<cr>"; options.desc = "Diagnostics"; }
      { mode = "n"; key = "<leader>sl"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; options.desc = "Line diagnostics"; }
      { mode = "n"; key = "<leader>sn"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; options.desc = "Next diagnostic"; }
      { mode = "n"; key = "<leader>sp"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; options.desc = "Prev diagnostic"; }
    ];

    # <leader>m → Meta (help, keymaps, introspection)
    meta = [
      { mode = "n"; key = "<leader>mh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help tags"; }
      { mode = "n"; key = "<leader>mk"; action = "<cmd>Telescope keymaps<cr>"; options.desc = "Search keymaps"; }
      { mode = "n"; key = "<leader>mm"; action = "<cmd>Telescope man_pages<cr>"; options.desc = "Man pages"; }
      { mode = "n"; key = "<leader>mg"; action = "<cmd>Glow<cr>"; options.desc = "Glow preview"; }
      { mode = "n"; key = "<leader>mp"; action = "<cmd>MarkdownPreview<cr>"; options.desc = "Markdown preview (browser)"; }
    ];
  };
}
