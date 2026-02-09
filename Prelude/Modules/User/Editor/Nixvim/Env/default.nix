# Env: 1-1 mapping from options
{ config, lib, ... }:
let cfg = config.nixvim; in
{
  config.nixvim.env = lib.mkIf cfg.enable ({
    NVIM_COLORSCHEME = cfg.colorscheme;
    NVIM_LEADER = cfg.leader;
    NVIM_LINE_NUMBERS = lib.boolToString cfg.lineNumbers;
    NVIM_RELATIVE_NUMBERS = lib.boolToString cfg.relativeNumbers;
    NVIM_TAB_WIDTH = toString cfg.tabWidth;
  } // lib.optionalAttrs cfg.preview.enable {
    PREVIEW_PORT = toString cfg.preview.port;
    PREVIEW_AUTO_SWITCH = lib.boolToString cfg.preview.autoSwitch;
    PREVIEW_BROWSER = cfg.preview.browser;
    PREVIEW_CONVERTERS = builtins.toJSON cfg.preview.converters;
  });
}
