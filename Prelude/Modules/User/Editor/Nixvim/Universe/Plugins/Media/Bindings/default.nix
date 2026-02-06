# Media plugins (.png, .jpg, .svg, .wav, .mp4 → preview)
{ config, lib, ... }:
{
  config.nixvim.plugins.media = lib.mkIf config.nixvim.enable {
    image = {
      enable = true;
      integrations.neorg.enable = false;
      integrations.markdown.enable = true;
    };
  };

  config.nixvim.keymaps.media = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>ip"; action = "<cmd>!open %<cr>"; options.desc = "Open in default app"; }
    { mode = "n"; key = "<leader>iw"; action = "<cmd>!ffplay -autoexit %<cr>"; options.desc = "Play audio/video"; }
  ];
}
