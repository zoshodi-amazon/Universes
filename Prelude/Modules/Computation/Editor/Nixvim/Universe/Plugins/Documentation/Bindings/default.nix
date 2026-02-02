# Documentation plugins (d2, glow, markdown-preview)
{ config, lib, ... }:
{
  config.nixvim.plugins.documentation = lib.mkIf config.nixvim.enable {
    glow.enable = true;
    markdown-preview = {
      enable = true;
      autoLoad = true;
    };
  };

  # d2-vim handled in Instances (needs pkgs)
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

  # Keymaps co-located with plugin
  config.nixvim.keymaps.documentation = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>mg"; action = "<cmd>Glow<cr>"; options.desc = "Glow preview"; }
    { mode = "n"; key = "<leader>mp"; action = "<cmd>MarkdownPreview<cr>"; options.desc = "Markdown preview (browser)"; }
    { mode = "n"; key = "<leader>md"; action = "<cmd>D2PreviewToggle<cr>"; options.desc = "D2 preview toggle"; }
    { mode = "v"; key = "<leader>md"; action = ":'<,'>D2PreviewSelection<cr>"; options.desc = "D2 preview selection"; }
    { mode = "v"; key = "<leader>mr"; action = ":'<,'>D2ReplaceSelection<cr>"; options.desc = "D2 replace with ASCII"; }
  ];
}
