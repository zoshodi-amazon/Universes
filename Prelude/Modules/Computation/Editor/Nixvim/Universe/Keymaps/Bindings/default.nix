# Keymap bindings - organized ontologically
# NOTE: Plugin-specific keymaps belong in their plugin's Bindings/, not here
{ ... }:
{
  config.nixvim.keymaps = {
    # Core vim motions (non-leader) - always available
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

    # <leader>c → Computation (code actions, format, eval, check) - LSP always available
    computation = [
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; options.desc = "Code actions"; }
      { mode = "n"; key = "<leader>cf"; action = "<cmd>lua vim.lsp.buf.format()<cr>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "<leader>cr"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; options.desc = "Rename symbol"; }
      { mode = "n"; key = "<leader>cb"; action = "<cmd>!nix build<cr>"; options.desc = "Nix build"; }
      { mode = "n"; key = "<leader>cc"; action = "<cmd>!nix flake check<cr>"; options.desc = "Nix flake check"; }
      { mode = "n"; key = "<leader>ce"; action = "<cmd>!nix eval<cr>"; options.desc = "Nix eval"; }
      { mode = "n"; key = "<leader>cR"; action = "<cmd>terminal nix repl<cr>"; options.desc = "Nix REPL"; }
    ];

    # <leader>s → Signal (diagnostics) - vim.diagnostic always available
    signal = [
      { mode = "n"; key = "<leader>sd"; action = "<cmd>lua vim.diagnostic.setloclist()<cr>"; options.desc = "Diagnostics list"; }
      { mode = "n"; key = "<leader>sl"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; options.desc = "Line diagnostics"; }
      { mode = "n"; key = "<leader>sn"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; options.desc = "Next diagnostic"; }
      { mode = "n"; key = "<leader>sp"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; options.desc = "Prev diagnostic"; }
    ];

    # <leader>m → Meta (help) - vim builtins
    meta = [
      { mode = "n"; key = "<leader>mh"; action = "<cmd>help<cr>"; options.desc = "Help"; }
    ];
  };
}
