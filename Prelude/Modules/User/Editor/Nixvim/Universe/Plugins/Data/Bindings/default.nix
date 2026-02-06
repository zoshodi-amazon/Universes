# Data plugins (.json, .yaml, .csv, .toml → tree/table view)
{ config, lib, ... }:
{
  config.nixvim.plugins.data = lib.mkIf config.nixvim.enable {
    # TOML LSP
    lsp.servers.taplo.enable = true;
  };

  config.nixvim.keymaps.data = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>dj"; action = "<cmd>%!jq .<cr>"; options.desc = "Format JSON (jq)"; }
    { mode = "n"; key = "<leader>dy"; action = "<cmd>%!yq .<cr>"; options.desc = "Format YAML (yq)"; }
    { mode = "v"; key = "<leader>dj"; action = ":'<,'>!jq .<cr>"; options.desc = "Format selection (jq)"; }
  ];
}
