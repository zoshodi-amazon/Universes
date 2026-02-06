# Languages plugins (.nix, .lean, .py, .rs, .ts → LSP + REPL)
{ config, lib, ... }:
{
  config.nixvim.plugins.languages = lib.mkIf config.nixvim.enable {
    # Nix
    nix.enable = true;
    
    # LSP
    lsp = {
      enable = true;
      servers = {
        nil_ls.enable = true;        # .nix
        nushell.enable = true;       # .nu
        pyright.enable = true;       # .py
        rust_analyzer = {            # .rs
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        ts_ls.enable = true;         # .ts
        lua_ls.enable = true;        # .lua
      };
    };
    
    # Lean (infoview split)
    lean = {
      enable = true;
      lsp.enable = true;
    };
  };

  config.nixvim.keymaps.languages = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>li"; action = "<cmd>LeanInfoviewToggle<cr>"; options.desc = "Lean infoview"; }
    { mode = "n"; key = "<leader>lr"; action = "<cmd>terminal<cr>"; options.desc = "Open terminal (REPL)"; }
  ];
}
