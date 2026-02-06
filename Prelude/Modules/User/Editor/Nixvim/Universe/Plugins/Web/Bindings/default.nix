# Web plugins (.html, .css, .jsx → live browser)
{ config, lib, ... }:
{
  config.nixvim.extraPluginConfigs.live-server = lib.mkIf config.nixvim.enable {
    owner = "barrett-ruth";
    repo = "live-server.nvim";
    rev = "main";
    sha256 = "0hfgcz01l38arz51szbcn9068zlsnf4wsh7f9js0jfw3r140gw6h";
    config = "";
  };

  config.nixvim.keymaps.web = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>wl"; action = "<cmd>LiveServerStart<cr>"; options.desc = "Live server start"; }
    { mode = "n"; key = "<leader>ws"; action = "<cmd>LiveServerStop<cr>"; options.desc = "Live server stop"; }
    { mode = "n"; key = "<leader>wo"; action = "<cmd>!open %<cr>"; options.desc = "Open in browser"; }
  ];
}
