# Inline: in-buffer rendering (images, markdown, diagrams)
{ config, lib, ... }:
{
  config.nixvim.plugins.inline = lib.mkIf config.nixvim.enable {
    image = {
      enable = true;
      integrations.neorg.enable = false;
      integrations.markdown.enable = true;
    };
    glow.enable = true;
  };

  config.nixvim.extraPluginConfigs.d2 = lib.mkIf config.nixvim.enable {
    owner = "terrastruct";
    repo = "d2-vim";
    rev = "master";
    sha256 = "0c6sg882mb6za9zgv83h1jcc9q9y0ppfqpm4q9vmyj98w9yd0q0y";
    config = ''
      let g:d2_fmt_autosave = 1
      let g:d2_ascii_autorender = 1
      let g:d2_ascii_preview_width = 80
    '';
  };

  config.nixvim.keymaps.inline = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>ig"; action = "<cmd>Glow<cr>"; options.desc = "Glow preview (inline)"; }
    { mode = "n"; key = "<leader>id"; action = "<cmd>D2PreviewToggle<cr>"; options.desc = "D2 preview toggle"; }
    { mode = "v"; key = "<leader>id"; action = ":'<,'>D2PreviewSelection<cr>"; options.desc = "D2 preview selection"; }
    { mode = "v"; key = "<leader>ir"; action = ":'<,'>D2ReplaceSelection<cr>"; options.desc = "D2 replace with ASCII"; }
    { mode = "n"; key = "<leader>io"; action = "<cmd>!open %<cr>"; options.desc = "Open in default app"; }
  ];
}
